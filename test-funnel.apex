// Test the getFunnelData method
CandidateFunnelController.FunnelData result = CandidateFunnelController.getFunnelData(false);
System.debug('Total Candidates: ' + result.totalCandidates);
System.debug('Stages: ' + result.stages.size());
for (CandidateFunnelController.FunnelStage stage : result.stages) {
    System.debug(stage.label + ': ' + stage.count);
}

// Test with activeOnly = true
CandidateFunnelController.FunnelData activeResult = CandidateFunnelController.getFunnelData(true);
System.debug('Active Only Total: ' + activeResult.totalCandidates);
