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
        @error = nil

        set_stages
        return if @stages.length == 0
        @commands.each do |command|
            command = command.split(" ")
            
            case command[0]
            when "CREATE"
                find_or_create_applicant(command[1])               
            when "ADVANCE"
                advance_applicant(command[1], command[2])
            when "DECIDE"
                decide_applicant(command[1], command[2])
            when "STATS"
                display_stats
            else
                return_error
            end
            return if @error
        end
        self.update_attributes(output: @output)
        self.save
        # raise @output.inspect
    end

    private

    def return_error
        self.output = "You have submitted improper input."
        self.save
        @error = true
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

    def find_or_create_applicant(email)
        if self.applicants.find_by(email: email)
            @output += "\nDuplicate applicant"
        else
            applicant = self.applicants.create(email: email)
            @output += "\nCREATE #{applicant.email}"
        end
    end

    def advance_applicant(email, stage = nil)
        applicant = self.applicants.find_by(email: email)
        return_error if !applicant
        
        if stage
            index = @stages.index(stage)
            if applicant.stage == index
                @output += "\nAlready in #{@stages[applicant.stage]}"
            else
                applicant.update_attributes(stage: index)
                @output += "\nASDVANCE #{applicant.email}"
            end  
        else
            if applicant.stage >= @stages.length - 1
                @output += "\nAlready in #{@stages[applicant.stage]}"
            else
                applicant.update_attributes(stage: applicant.stage + 1)
                @output += "\nADVANCE #{applicant.email}"
            end
        end

    end

    def decide_applicant(email, decision)
        applicant = self.applicants.find_by(email: email)
        return_error if !applicant

        if decision == "0"
            applicant.update_attributes(hired: 0)
            @output += "\nRejected #{applicant.email}"
        elsif decision == "1" && applicant.stage >= @stages.length - 1
            applicant.update_attributes(hired: 1)
            @output += "\nHired #{applicant.email}"
        else
            @output += "\nFailed to decide for #{applicant.email}"
        end
    end
end
