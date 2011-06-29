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

require_dependency "resources/pulp"

module Glue::Pulp::Consumer
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, LazyAccessor
    base.class_eval do
      before_destroy :destroy_pulp_orchestration
      lazy_accessor :pulp_facts, :initializer => lambda { Pulp::Consumer.find(uuid)}
      lazy_accessor :packages, :initializer => lambda { Pulp::Consumer.installed_packages(uuid).
                                                              collect{|pack| Glue::Pulp::SimplePackage.new(pack)}}
    end
  end
  module InstanceMethods
    def del_pulp_consumer
      Rails.logger.info "Deleting consumer in pulp: #{name}"
      Pulp::Consumer.destroy(self.uuid)
    rescue => e
      Rails.logger.error "Failed to delete pulp consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end


    def destroy_pulp_orchestration
      queue.create(:name => "delete pulp consumer: #{self.name}", :priority => 3, :action => [self, :del_pulp_consumer])
    end


  end
end