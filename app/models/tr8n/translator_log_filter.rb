#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
#
#-- Tr8n::TranslatorLogFilter Schema Information
#
# Table name: will_filter_filters
#
#  id                  INTEGER         not null, primary key
#  type                varchar(255)    
#  name                varchar(255)    
#  data                text            
#  user_id             integer         
#  model_class_name    varchar(255)    
#  created_at          datetime        
#  updated_at          datetime        
#
# Indexes
#
#  index_will_filter_filters_on_user_id    (user_id) 
#
#++

class Tr8n::TranslatorLogFilter < Tr8n::BaseFilter

  def model_class
    Tr8n::TranslatorLog
  end

  def definition
    defs = super  
    defs[:action][:is] = :list
    defs[:action][:is_not] = :list
    defs
  end

  def value_options_for(criteria_key)
    if criteria_key == :action
      return Tr8n::TranslatorLog::ACTIONS
    end

    return []
  end
  
  def default_filter_if_empty
    "created_today"
  end
  
  def inner_joins
    [:translator]
  end
  
end
