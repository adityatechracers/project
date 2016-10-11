class LeadUpload < ActiveRecord::Base
  attr_accessible :name, :csv
  has_attached_file :csv

  def contents
    CSV.read(self.csv.path)
  end
  def header
    self.contents.shift()
  end
  def header_options
    self.header.unshift("")
  end
  def body
    c = self.contents
    c.shift()
    c
  end
  def hashed_contents
    output = []
    self.body.each do |row|
      o = {}
      self.header.each_with_index {|h,i| o[h] = row[i]}
      output << o
    end
    output
  end
  def process(mapping)
    # Delete the blanks
    mapping = mapping.delete_if{|k,v| v.blank?}

    count = 0
    self.hashed_contents.each do |row|
      # CREATE CONTACT
      contact = Contact.new map_params(row,mapping)
      return "Import failed, please check your mapping and try again." unless contact.save
      Job.create({:contact_id => contact.id})
      count += 1
    end
    count
  end

  def map_params(row,map)
    hash = {}
    map.each {|attr_name, csv_name| hash[attr_name] = row[csv_name]}
    hash
  end
end

# == Schema Information
#
# Table name: lead_uploads
#
#  id               :integer          not null, primary key
#  csv_file_name    :string(255)
#  csv_content_type :string(255)
#  csv_file_size    :integer
#  csv_updated_at   :datetime
#  name             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
