#   Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
 
#       http://www.apache.org/licenses/LICENSE-2.0
 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

require_relative '../../../Synthax/Attributes/enum_case.rb'
require_relative '../../base_component.rb'
require_relative '../../../Synthax/Types/enum_type.rb'

class JustifyContent < BaseComponent

    def initialize
        enum_cases = [
            EnumCase.new(:name => "flexStart", :defaultValue => "FLEX_START"),
            EnumCase.new(:name => "center", :defaultValue => "CENTER"),
            EnumCase.new(:name => "flexEnd", :defaultValue => "FLEX_END"),
            EnumCase.new(:name => "spaceBetween", :defaultValue => "SPACE_BETWEEN"),
            EnumCase.new(:name => "spaceAround", :defaultValue => "SPACE_AROUND"),
            EnumCase.new(:name => "spaceEvenly", :defaultValue => "SPACE_EVENLY")
        ]
        synthax_type = EnumType.new(
            :name => self.name,
            :variables => enum_cases,
            :inheritFrom => [BasicTypeKeys.string],
            :package => "br.com.zup.beagle.widget.core"
        )

        super(synthax_type)

    end

end