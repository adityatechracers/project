namespace :data do
  desc "Add an 'upload your own proposal' template for every organization"
  task prep_upload_proposal: :environment do
    puts("Setting all current proposal files as AttachmentProposalFiles...")
    ProposalFile.find_each do |f|
      puts("Proposal file id #{f.id}... Updating")
      f.type = AttachmentProposalFile.name
      f.save
    end

    puts("Proposal file statuses have been updated")
    puts("-------")

    puts("Adding global 'upload your own' proposal template...")
    global_p = ProposalTemplate.new(active: true, name: 'Upload Your Own', organization_id: 0, type: PersonalProposalTemplate.name)
    global_p.save
    puts("-------")

    Organization.find_each do |org|
      puts("Organization id #{org.id}... Adding template")
      p = ProposalTemplate.new(active: true, name: 'Upload Your Own', organization_id: org.id, type: PersonalProposalTemplate.name)
      p.save
    end
    puts "Proposal templates have been added."
  end
end
