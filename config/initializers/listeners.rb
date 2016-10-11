Wisper.subscribe(JobScheduleEntryListener.new, scope: :JobScheduleEntry)
Wisper.subscribe(QbProposalListener.new, scope: [:Job, :Proposal])