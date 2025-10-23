#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ErrorCode,
  ListToolsRequestSchema,
  McpError,
} from '@modelcontextprotocol/sdk/types.js';
import { Connection } from '@salesforce/core';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

interface SalesforceConfig {
  username?: string;
  loginUrl?: string;
  instanceUrl?: string;
}

class RecruitingMCPServer {
  private server: Server;
  private sfConnection: Connection | null = null;

  constructor() {
    this.server = new Server(
      {
        name: 'recruiting-context-mcp-server',
        version: '1.0.0',
      }
    );

    this.setupToolHandlers();
    this.setupErrorHandling();
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error('[MCP Error]', error);
    };

    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  private setupToolHandlers(): void {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'get_candidates',
            description: 'Retrieve candidate information from Interview__c records',
            inputSchema: {
              type: 'object',
              properties: {
                status: {
                  type: 'string',
                  description: 'Filter by interview status',
                  enum: ['Scheduled', 'Completed', 'Cancelled', 'Rescheduled']
                },
                limit: {
                  type: 'number',
                  description: 'Maximum number of records to return',
                  default: 10
                }
              }
            }
          },
          {
            name: 'schedule_interview',
            description: 'Schedule a new interview for a candidate',
            inputSchema: {
              type: 'object',
              properties: {
                candidateId: {
                  type: 'string',
                  description: 'ID of the candidate'
                },
                interviewType: {
                  type: 'string',
                  description: 'Type of interview (Phone, Video, In-Person)'
                },
                scheduledDateTime: {
                  type: 'string',
                  description: 'Scheduled date and time in ISO format'
                },
                conductedBy: {
                  type: 'string',
                  description: 'ID of the interviewer'
                },
                notes: {
                  type: 'string',
                  description: 'Additional notes for the interview'
                }
              },
              required: ['candidateId', 'interviewType', 'scheduledDateTime', 'conductedBy']
            }
          },
          {
            name: 'update_interview_outcome',
            description: 'Update the outcome of a completed interview',
            inputSchema: {
              type: 'object',
              properties: {
                interviewId: {
                  type: 'string',
                  description: 'ID of the interview record'
                },
                outcome: {
                  type: 'string',
                  description: 'Interview outcome',
                  enum: ['Hired', 'Not Selected', 'Next Round', 'On Hold']
                },
                notes: {
                  type: 'string',
                  description: 'Interview notes and feedback'
                }
              },
              required: ['interviewId', 'outcome']
            }
          },
          {
            name: 'get_recruiter_dashboard_data',
            description: 'Get dashboard data for the recruiting portal',
            inputSchema: {
              type: 'object',
              properties: {
                recruiterId: {
                  type: 'string',
                  description: 'ID of the recruiter'
                },
                dateRange: {
                  type: 'string',
                  description: 'Date range for dashboard data',
                  enum: ['today', 'this_week', 'this_month', 'this_quarter']
                }
              }
            }
          },
          {
            name: 'reschedule_interview',
            description: 'Reschedule an existing interview',
            inputSchema: {
              type: 'object',
              properties: {
                interviewId: {
                  type: 'string',
                  description: 'ID of the interview to reschedule'
                },
                newDateTime: {
                  type: 'string',
                  description: 'New scheduled date and time in ISO format'
                },
                reason: {
                  type: 'string',
                  description: 'Reason for rescheduling'
                }
              },
              required: ['interviewId', 'newDateTime']
            }
          },
          {
            name: 'read_apex_file',
            description: 'Read Salesforce Apex class or trigger files from the project',
            inputSchema: {
              type: 'object',
              properties: {
                fileName: {
                  type: 'string',
                  description: 'Name of the Apex file to read (e.g., RecruiterDashboardController.cls)'
                },
                filePath: {
                  type: 'string',
                  description: 'Optional full path to the file'
                }
              },
              required: ['fileName']
            }
          }
        ]
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        await this.ensureSalesforceConnection();

        switch (name) {
          case 'get_candidates':
            return await this.getCandidates(args);
          case 'schedule_interview':
            return await this.scheduleInterview(args);
          case 'update_interview_outcome':
            return await this.updateInterviewOutcome(args);
          case 'get_recruiter_dashboard_data':
            return await this.getRecruiterDashboardData(args);
          case 'reschedule_interview':
            return await this.rescheduleInterview(args);
          case 'read_apex_file':
            return await this.readApexFile(args);
          default:
            throw new McpError(
              ErrorCode.MethodNotFound,
              `Unknown tool: ${name}`
            );
        }
      } catch (error) {
        console.error(`Error executing tool ${name}:`, error);
        throw new McpError(
          ErrorCode.InternalError,
          `Error executing ${name}: ${error instanceof Error ? error.message : String(error)}`
        );
      }
    });
  }

  private async ensureSalesforceConnection(): Promise<void> {
    if (!this.sfConnection) {
      const config: SalesforceConfig = {
        username: process.env.SALESFORCE_USERNAME,
        loginUrl: process.env.SALESFORCE_LOGIN_URL || 'https://login.salesforce.com',
        instanceUrl: process.env.SALESFORCE_INSTANCE_URL
      };

      if (!config.username) {
        throw new Error('SALESFORCE_USERNAME environment variable is required');
      }

      try {
        // Use default org from Salesforce CLI
        const { AuthInfo } = await import('@salesforce/core');
        const authInfo = await AuthInfo.create({ username: config.username });
        this.sfConnection = await Connection.create({ authInfo });
      } catch (error) {
        console.error('Failed to create Salesforce connection:', error);
        throw new Error('Unable to connect to Salesforce. Please ensure you are authenticated with the Salesforce CLI.');
      }
    }
  }

  private async getCandidates(args: any) {
    const { status, limit = 10 } = args || {};
    
    let query = `
      SELECT Id, Candidate__c, Interview_Status__c, Interview_Type__c, 
             Conducted_By__c, Notes__c, Outcome__c, CreatedDate, LastModifiedDate
      FROM Interview__c
    `;
    
    if (status) {
      query += ` WHERE Interview_Status__c = '${status}'`;
    }
    
    query += ` ORDER BY CreatedDate DESC LIMIT ${limit}`;

    const result = await this.sfConnection!.query(query);
    
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({
            success: true,
            data: result.records,
            totalSize: result.totalSize
          }, null, 2)
        }
      ]
    };
  }

  private async scheduleInterview(args: any) {
    const { candidateId, interviewType, scheduledDateTime, conductedBy, notes } = args;
    
    const interviewRecord = {
      Candidate__c: candidateId,
      Interview_Type__c: interviewType,
      Interview_Status__c: 'Scheduled',
      Conducted_By__c: conductedBy,
      Notes__c: notes || ''
    };

    const result = await this.sfConnection!.sobject('Interview__c').create(interviewRecord);
    
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({
            success: true,
            interviewId: result.id,
            message: 'Interview scheduled successfully'
          }, null, 2)
        }
      ]
    };
  }

  private async updateInterviewOutcome(args: any) {
    const { interviewId, outcome, notes } = args;
    
    const updateData: any = {
      Interview_Status__c: 'Completed',
      Outcome__c: outcome
    };
    
    if (notes) {
      updateData.Notes__c = notes;
    }

    const result = await this.sfConnection!.sobject('Interview__c').update({
      Id: interviewId,
      ...updateData
    });
    
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({
            success: true,
            result: result,
            message: 'Interview outcome updated successfully'
          }, null, 2)
        }
      ]
    };
  }

  private async getRecruiterDashboardData(args: any) {
    const { recruiterId, dateRange = 'this_week' } = args || {};
    
    // Build date filter based on range
    let dateFilter = '';
    const today = new Date();
    
    switch (dateRange) {
      case 'today':
        dateFilter = `CreatedDate = TODAY`;
        break;
      case 'this_week':
        dateFilter = `CreatedDate = THIS_WEEK`;
        break;
      case 'this_month':
        dateFilter = `CreatedDate = THIS_MONTH`;
        break;
      case 'this_quarter':
        dateFilter = `CreatedDate = THIS_QUARTER`;
        break;
    }

    // Get interview statistics
    const statsQuery = `
      SELECT Interview_Status__c, COUNT(Id) recordCount
      FROM Interview__c
      WHERE ${dateFilter}
      ${recruiterId ? `AND Conducted_By__c = '${recruiterId}'` : ''}
      GROUP BY Interview_Status__c
    `;

    // Get recent interviews
    const recentQuery = `
      SELECT Id, Candidate__c, Interview_Status__c, Interview_Type__c, 
             Conducted_By__c, CreatedDate
      FROM Interview__c
      WHERE ${dateFilter}
      ${recruiterId ? `AND Conducted_By__c = '${recruiterId}'` : ''}
      ORDER BY CreatedDate DESC
      LIMIT 20
    `;

    const [statsResult, recentResult] = await Promise.all([
      this.sfConnection!.query(statsQuery),
      this.sfConnection!.query(recentQuery)
    ]);

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({
            success: true,
            statistics: statsResult.records,
            recentInterviews: recentResult.records,
            dateRange,
            recruiterId
          }, null, 2)
        }
      ]
    };
  }

  private async rescheduleInterview(args: any) {
    const { interviewId, newDateTime, reason } = args;
    
    const updateData = {
      Interview_Status__c: 'Rescheduled',
      Notes__c: reason ? `Rescheduled: ${reason}` : 'Interview rescheduled'
    };

    const result = await this.sfConnection!.sobject('Interview__c').update({
      Id: interviewId,
      ...updateData
    });
    
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({
            success: true,
            result: result,
            message: 'Interview rescheduled successfully',
            newDateTime
          }, null, 2)
        }
      ]
    };
  }

  private async readApexFile(args: any) {
    const { fileName, filePath } = args;
    
    try {
      const fs = await import('fs/promises');
      const path = await import('path');
      
      let fullPath = filePath;
      
      if (!fullPath) {
        // Search for the file in common Apex locations
        const projectRoot = 'c:\\SF Projects VS Code\\SalesforceRecruiterPortal\\RecruiterPortal';
        const possiblePaths = [
          path.join(projectRoot, 'force-app', 'main', 'default', 'classes', fileName),
          path.join(projectRoot, 'force-app', 'main', 'default', 'triggers', fileName),
          path.join(projectRoot, 'classes', fileName),
          path.join(projectRoot, 'triggers', fileName)
        ];
        
        for (const possiblePath of possiblePaths) {
          try {
            await fs.access(possiblePath);
            fullPath = possiblePath;
            break;
          } catch {
            continue;
          }
        }
      }
      
      if (!fullPath) {
        throw new Error(`File ${fileName} not found in project`);
      }
      
      const content = await fs.readFile(fullPath, 'utf-8');
      
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              success: true,
              fileName: fileName,
              filePath: fullPath,
              content: content,
              lines: content.split('\n').length
            }, null, 2)
          }
        ]
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              success: false,
              error: error instanceof Error ? error.message : String(error),
              fileName: fileName
            }, null, 2)
          }
        ]
      };
    }
  }

  async run(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Recruiting Context MCP Server running on stdio');
  }
}

const server = new RecruitingMCPServer();
server.run().catch(console.error);