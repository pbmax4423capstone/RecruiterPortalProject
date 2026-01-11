public with sharing class KnowledgeSearchController {
    public class ArticleDTO {
        @AuraEnabled public Id id;
        @AuraEnabled public String title;
        @AuraEnabled public String summary;
        @AuraEnabled public String urlName;
        @AuraEnabled public String articleNumber;
    }

    @AuraEnabled(cacheable=true)
    public static List<ArticleDTO> search(String query, Integer limitSize, String language) {
        Integer lim = (limitSize == null || limitSize <= 0) ? 10 : Math.min(limitSize, 50);
        String lang = String.isBlank(language) ? UserInfo.getLanguage() : language;
        String likePattern = '%' + (query == null ? '' : query.trim()) + '%';

        List<ArticleDTO> results = new List<ArticleDTO>();
                for (Knowledge__kav kav : [
            SELECT Id, Title, Summary, UrlName, ArticleNumber
                        FROM Knowledge__kav
                        WHERE PublishStatus = 'Online'
              AND Language = :lang
                            AND (Title LIKE :likePattern OR Summary LIKE :likePattern)
            ORDER BY LastPublishedDate DESC
                        LIMIT :lim
                ]) {
            ArticleDTO dto = new ArticleDTO();
            dto.id = kav.Id;
            dto.title = kav.Title;
            dto.summary = kav.Summary;
            dto.urlName = kav.UrlName;
            dto.articleNumber = kav.ArticleNumber;
            results.add(dto);
        }
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static List<ArticleDTO> suggestByCase(Id caseId, Integer limitSize) {
        if (caseId == null) return new List<ArticleDTO>();
        Case c = [SELECT Subject FROM Case WHERE Id = :caseId LIMIT 1];
        return search(c.Subject, limitSize, null);
    }
}
