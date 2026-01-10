public with sharing class InterviewLeaderboardController {
  public class LeaderboardEntry {
    @AuraEnabled
    public String managerId { get; set; }
    @AuraEnabled
    public String managerName { get; set; }
    @AuraEnabled
    public String profileName { get; set; }
    @AuraEnabled
    public Integer activeCandidates { get; set; }
    @AuraEnabled
    public Integer totalCandidates { get; set; }
    @AuraEnabled
    public Integer interviewsThisWeek { get; set; }
    @AuraEnabled
    public Integer interviewsThisMonth { get; set; }
    @AuraEnabled
    public Integer interviewsThisYear { get; set; }
    @AuraEnabled
    public Integer callsThisWeek { get; set; }
    @AuraEnabled
    public Integer callsThisMonth { get; set; }
    @AuraEnabled
    public Integer callsThisYear { get; set; }
    @AuraEnabled
    public InterviewBreakdown weekBreakdown { get; set; }
    @AuraEnabled
    public InterviewBreakdown monthBreakdown { get; set; }
    @AuraEnabled
    public InterviewBreakdown yearBreakdown { get; set; }
  }

  public class InterviewBreakdown {
    @AuraEnabled
    public Integer citInterviews { get; set; }
    @AuraEnabled
    public Integer alignInterviews { get; set; }
    @AuraEnabled
    public Integer planInterviews { get; set; }
    @AuraEnabled
    public Integer presentInterviews { get; set; }
    @AuraEnabled
    public Integer optionalInterviews { get; set; }
    @AuraEnabled
    public Integer totalInterviews { get; set; }

    public InterviewBreakdown() {
      this.citInterviews = 0;
      this.alignInterviews = 0;
      this.planInterviews = 0;
      this.presentInterviews = 0;
      this.optionalInterviews = 0;
      this.totalInterviews = 0;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<LeaderboardEntry> getLeaderboardData() {
    List<LeaderboardEntry> leaderboard = new List<LeaderboardEntry>();

    try {
      // Get all active Sales Managers and Recruiters
      List<User> salesManagers = [
        SELECT Id, Name, Profile.Name
        FROM User
        WHERE
          IsActive = TRUE
          AND (Profile.Name LIKE '%Sales%Manager%'
          OR Profile.Name LIKE '%Recruiting%Manager%'
          OR Profile.Name LIKE '%Recruiter%'
          OR Name LIKE '%Manager%')
        ORDER BY Name
        LIMIT 10
      ];

      for (User manager : salesManagers) {
        LeaderboardEntry entry = new LeaderboardEntry();
        entry.managerId = manager.Id;
        entry.managerName = manager.Name;
        entry.profileName = manager.Profile.Name;

        // Get candidate counts
        entry.activeCandidates = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :manager.Id AND Status__c = 'Active/In Process'
        ];

        entry.totalCandidates = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :manager.Id
        ];

        // Get interview breakdowns for month only (to reduce SOQL queries)
        entry.monthBreakdown = getInterviewBreakdown(manager.Id, 'THIS_MONTH');
        entry.interviewsThisMonth = entry.monthBreakdown.totalInterviews;

        // Set week and year to null to save queries
        entry.weekBreakdown = new InterviewBreakdown();
        entry.yearBreakdown = new InterviewBreakdown();
        entry.interviewsThisWeek = 0;
        entry.interviewsThisYear = 0;

        // Get call counts - month only
        entry.callsThisMonth = [
          SELECT COUNT()
          FROM Task
          WHERE
            OwnerId = :manager.Id
            AND (Subject LIKE '%Call%'
            OR TaskSubtype = 'Call')
            AND IsClosed = TRUE
            AND ActivityDate = THIS_MONTH
        ];

        // Set week and year to 0 to save queries
        entry.callsThisWeek = 0;
        entry.callsThisYear = 0;

        leaderboard.add(entry);
      }
    } catch (Exception e) {
      System.debug('Error in getLeaderboardData: ' + e.getMessage());
      throw new AuraHandledException(
        'Error retrieving leaderboard data: ' + e.getMessage()
      );
    }

    return leaderboard;
  }

  private static InterviewBreakdown getInterviewBreakdown(
    Id managerId,
    String timeFrame
  ) {
    InterviewBreakdown breakdown = new InterviewBreakdown();

    try {
      // CIT (1st) Interviews
      if (timeFrame == 'THIS_WEEK') {
        breakdown.citInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE
            OwnerId = :managerId
            AND (AI_Completed_Date_Time__c = THIS_WEEK
            OR Attraction_Interview_Date_Completed__c = THIS_WEEK)
        ];
      } else if (timeFrame == 'THIS_MONTH') {
        breakdown.citInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE
            OwnerId = :managerId
            AND (AI_Completed_Date_Time__c = THIS_MONTH
            OR Attraction_Interview_Date_Completed__c = THIS_MONTH)
        ];
      } else if (timeFrame == 'THIS_YEAR') {
        breakdown.citInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE
            OwnerId = :managerId
            AND (AI_Completed_Date_Time__c = THIS_YEAR
            OR Attraction_Interview_Date_Completed__c = THIS_YEAR)
        ];
      }

      // Align (2nd) Interviews
      if (timeFrame == 'THIS_WEEK') {
        breakdown.alignInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :managerId AND SI_1_Date_Completed__c = THIS_WEEK
        ];
      } else if (timeFrame == 'THIS_MONTH') {
        breakdown.alignInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :managerId AND SI_1_Date_Completed__c = THIS_MONTH
        ];
      } else if (timeFrame == 'THIS_YEAR') {
        breakdown.alignInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :managerId AND SI_1_Date_Completed__c = THIS_YEAR
        ];
      }

      // Plan (3rd) Interviews
      if (timeFrame == 'THIS_WEEK') {
        breakdown.planInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :managerId AND SI_2_Date_Completed__c = THIS_WEEK
        ];
      } else if (timeFrame == 'THIS_MONTH') {
        breakdown.planInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :managerId AND SI_2_Date_Completed__c = THIS_MONTH
        ];
      } else if (timeFrame == 'THIS_YEAR') {
        breakdown.planInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :managerId AND SI_2_Date_Completed__c = THIS_YEAR
        ];
      }

      // Present (4th) Interviews
      if (timeFrame == 'THIS_WEEK') {
        breakdown.presentInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :managerId AND SI_3_Completed__c = THIS_WEEK
        ];
      } else if (timeFrame == 'THIS_MONTH') {
        breakdown.presentInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :managerId AND SI_3_Completed__c = THIS_MONTH
        ];
      } else if (timeFrame == 'THIS_YEAR') {
        breakdown.presentInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE OwnerId = :managerId AND SI_3_Completed__c = THIS_YEAR
        ];
      }

      // Optional (5th) Interviews
      if (timeFrame == 'THIS_WEEK') {
        breakdown.optionalInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE
            OwnerId = :managerId
            AND Career_Presentation_Date_Completed__c = THIS_WEEK
        ];
      } else if (timeFrame == 'THIS_MONTH') {
        breakdown.optionalInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE
            OwnerId = :managerId
            AND Career_Presentation_Date_Completed__c = THIS_MONTH
        ];
      } else if (timeFrame == 'THIS_YEAR') {
        breakdown.optionalInterviews = [
          SELECT COUNT()
          FROM Candidate__c
          WHERE
            OwnerId = :managerId
            AND Career_Presentation_Date_Completed__c = THIS_YEAR
        ];
      }

      // Calculate total
      breakdown.totalInterviews =
        breakdown.citInterviews +
        breakdown.alignInterviews +
        breakdown.planInterviews +
        breakdown.presentInterviews +
        breakdown.optionalInterviews;
    } catch (Exception e) {
      System.debug('Error in getInterviewBreakdown: ' + e.getMessage());
    }

    return breakdown;
  }

  @AuraEnabled(cacheable=true)
  public static List<LeaderboardEntry> getTopPerformers(
    String metric,
    String timeFrame,
    Integer topN
  ) {
    List<LeaderboardEntry> allData = getLeaderboardData();

    // Sort based on metric
    if (metric == 'interviews') {
      if (timeFrame == 'week') {
        allData.sort(new InterviewWeekComparator());
      } else if (timeFrame == 'month') {
        allData.sort(new InterviewMonthComparator());
      } else if (timeFrame == 'year') {
        allData.sort(new InterviewYearComparator());
      }
    } else if (metric == 'calls') {
      if (timeFrame == 'week') {
        allData.sort(new CallWeekComparator());
      } else if (timeFrame == 'month') {
        allData.sort(new CallMonthComparator());
      } else if (timeFrame == 'year') {
        allData.sort(new CallYearComparator());
      }
    }

    // Return top N
    List<LeaderboardEntry> topPerformers = new List<LeaderboardEntry>();
    for (Integer i = 0; i < Math.min(topN, allData.size()); i++) {
      topPerformers.add(allData[i]);
    }

    return topPerformers;
  }

  // Comparator classes for sorting
  class InterviewWeekComparator implements Comparator<LeaderboardEntry> {
    public Integer compare(LeaderboardEntry a, LeaderboardEntry b) {
      return b.interviewsThisWeek - a.interviewsThisWeek;
    }
  }

  class InterviewMonthComparator implements Comparator<LeaderboardEntry> {
    public Integer compare(LeaderboardEntry a, LeaderboardEntry b) {
      return b.interviewsThisMonth - a.interviewsThisMonth;
    }
  }

  class InterviewYearComparator implements Comparator<LeaderboardEntry> {
    public Integer compare(LeaderboardEntry a, LeaderboardEntry b) {
      return b.interviewsThisYear - a.interviewsThisYear;
    }
  }

  class CallWeekComparator implements Comparator<LeaderboardEntry> {
    public Integer compare(LeaderboardEntry a, LeaderboardEntry b) {
      return b.callsThisWeek - a.callsThisWeek;
    }
  }

  class CallMonthComparator implements Comparator<LeaderboardEntry> {
    public Integer compare(LeaderboardEntry a, LeaderboardEntry b) {
      return b.callsThisMonth - a.callsThisMonth;
    }
  }

  class CallYearComparator implements Comparator<LeaderboardEntry> {
    public Integer compare(LeaderboardEntry a, LeaderboardEntry b) {
      return b.callsThisYear - a.callsThisYear;
    }
  }
}
