class Proposal
  index: ->
    cork.Communication.Notes.activate()

cork.Proposal = Proposal

$ -> 
	$('#proposal_u_f').click -> $('#new_proposal_file').submit()