ProposalTemplate.seed_once(:name, :organization_id,
  {
    name: 'Empty Proposal',
    organization_id: 0
  },
  {
    name: 'Painting Proposal',
    organization_id: 0,
    section_templates_attributes: [
      {
        name:"Preparation",
        show_include_exclude_options: true,
        default_description: "This project description would pre-fill in from a settings area because it would most likely be very similar across projects.",
        background_color: "#8C2300",
        foreground_color: "#FFFFFF",
        position: 1,
        item_templates_attributes: [
          {
            name: "Washing",
            default_note_text:nil,
            help_text:nil,
            default_include_exclude_option:"Include"
          },
          {
            name: "Caulking",
            default_note_text:nil,
            help_text:nil,
            default_include_exclude_option:"N/A"
          },
          {
            name: "Puttying",
            default_note_text:nil,
            help_text:nil,
            default_include_exclude_option:"Include"
          },
          {
            name: "Other",
            default_note_text:nil,
            help_text:nil,
            default_include_exclude_option:"Include"
          },
          {
            name: "Surface Prep Level 1",
            default_note_text:nil,
            help_text:nil,
            default_include_exclude_option:"Include"
          },
          {
            name: "Surface Prep Level 2",
            default_note_text:nil,
            help_text:nil,
            default_include_exclude_option:"Include"
          }
        ]
      },
      {
        name:"Work to be Performed",
        show_include_exclude_options: true,
        default_description: "This project description would pre-fill in from a settings area because it would most likely be very similar across projects.",
        background_color: "#B25900",
        foreground_color: "#FFFFFF",
        position: 2,
        item_templates_attributes: [
          {
            name: "Paint Brand",
            default_note_text:"Sherwin Williams",
            help_text:"Sherwin Williams,  Dutch Boy, Bear, Kilz",
            default_include_exclude_option:"Include"
          },
          {
            name: "Fascia and Soffits",
            default_note_text:"1, Glossy, Latex, Color",
            help_text:"# Coats, Brand, Gloss Level, Paint Spec., Color",
            default_include_exclude_option:"Include"
          },
          {
            name: "Siding",
            default_note_text:nil,
            help_text:"# Coats, Brand, Gloss Level, Paint Spec., Color",
            default_include_exclude_option:"N/A"
          },
          {
            name: "Shutters",
            default_note_text:nil,
            help_text:"# Coats, Brand, Gloss Level, Paint Spec., Color",
            default_include_exclude_option:"Include"
          },
          {
            name: "Porch Ceiling",
            default_note_text:nil,
            help_text:"# Coats, Brand, Gloss Level, Paint Spec., Color",
            default_include_exclude_option:"Include"
          }
        ]
      },
      {
        name: "Clean Up",
        show_include_exclude_options: false,
        default_description: "We will pick up all our stuff. Unless we don’t, then you can.",
        background_color: "#0059B2",
        foreground_color: "#FFFFFF",
        position: 3
      },
      {
        name:"Payments",
        show_include_exclude_options: false,
        default_description: nil,
        background_color: "#008C00",
        foreground_color: "#FFFFFF",
        position: 4,
        item_templates_attributes: [
          {
            name: "Labor",
            default_note_text:"$1,000",
            help_text:"Total cost of the project."
          },
          {
            name: "Materials",
            default_note_text:"$1,000",
            help_text:"Material cost"
          },
          {
            name: "Tax",
            default_note_text:"$0",
            help_text:"6% in Michigan"
          },
          {
            name: "Total",
            default_note_text:"$2,000",
            help_text:nil
          },
          {
            name: "Deposit",
            default_note_text:"$300",
            help_text:"Typically 15% of the total"
          },
          {
            name: "Upon Completion",
            default_note_text:"$1,700",
            help_text:"Typically 85% of the total"
          }
        ]
      },
      {
        name:"Additional Work to be Performed",
        show_include_exclude_options: true,
        default_description: nil,
        background_color: "#666666",
        foreground_color: "#FFFFFF",
        position: 5,
        item_templates_attributes: [
          {
            name: "Other",
            default_note_text:"Deck $1,700 will powerwash, end of week paint.",
            help_text:"Details on Additional Work",
            default_include_exclude_option:"N/A"
          },
          {
            name: "Other",
            default_note_text:nil,
            help_text:"Details on Additional Work",
            default_include_exclude_option:"N/A"
          }
        ]
      }
    ]
  },
  {
    name: 'Roofing Proposal',
    organization_id: 0
  }
)
