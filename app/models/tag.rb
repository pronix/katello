#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'util/model_util'

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :permission

  # used for user-friendly presentation of this record
  def display_name
    name
  end

  def self.tags_for(resource_type_name)

    # step 1 - try to load tags from our model classes
    resource_type_name = resource_type_name.gsub('ar_', '')
    table_to_class = Katello::ModelUtils.table_to_model_hash
    if table_to_class.key?(resource_type_name)
      model_klass = table_to_class[resource_type_name]
      return model_klass.list_tags if model_klass.respond_to? :list_tags
    end

    # step 2 - fetch information from the database
    Tag.select('DISTINCT(tags.name)').joins(:permission => :resource_type).where(:resource_types => { :name => resource_type_name })
  end

end
