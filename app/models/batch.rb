class Batch < ActiveRecord::Base
    has_many :applicants

    AVAILABLE_STAGES = [
        'ManualReview',
        'PhoneInterview',
        'BackgroundCheck',
        'DocumentSigning'
    ]

    def parse_input
        @commands = input.split("\n")
        @stages = []
        @output = ""

        set_stages
        return if @stages.length == 0
        @commands.each do |command|
            command = command.split(" ")
            
            case command[0]
            when "CREATE"
                find_or_create_user(command[1])               
            when "ADVANCE"
                advance_user(command[1], command[2])
            when "DECIDE"
                decide_user(command[1], command[2])
            when "STATS"
                display_stats
            else
                return_error
                return
            end

        end
        self.update_attributes(output: @output)
        self.save
        raise @output.inspect
    end

    private

    def return_error
        self.output = "You have submitted improper input."
        self.save
    end

    def set_stages
        if !@commands[0].start_with? "DEFINE"
            return_error
        else
            stages = @commands[0].split(" ")
            stages.shift
            stages.each do |stage|
                @stages << stage if AVAILABLE_STAGES.include? stage
            end
            @output += "DEFINE #{@stages.join(' ')}"
        end
        @commands.shift
    end

    def find_or_create_user(email)
        if self.applicants.find_by(email: email)
            @output += "\nDuplicate applicant"
        else
            applicant = self.applicants.create(email: email)
            @output += "\nCREATE #{applicant.email}"
        end
    end
end
