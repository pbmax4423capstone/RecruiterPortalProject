// Activate version 2 of the flow (original before my changes)
Metadata.DeployContainer container = new Metadata.DeployContainer();
Metadata.FlowDefinition flowDef = new Metadata.FlowDefinition();
flowDef.fullName = 'Add_Contact_Name_to_Newly_Created_Activity_Record';
flowDef.activeVersionNumber = 2;
container.addMetadata(flowDef);
Id jobId = Metadata.Operations.enqueueDeployment(container, null);
System.debug('Deployment Job ID: ' + jobId);
