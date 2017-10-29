class Batch < ActiveRecord::Base
    has_many :applicants

    def parse_input
        self.output = self.input
        self.save
    end
end
