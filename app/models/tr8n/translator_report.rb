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
#-- Tr8n::TranslatorReport Schema Information
#
# Table name: tr8n_translator_reports
#
#  id               INTEGER         not null, primary key
#  translator_id    integer         
#  state            varchar(255)    
#  object_id        integer         
#  object_type      varchar(255)    
#  reason           varchar(255)    
#  comment          text            
#  created_at       datetime        
#  updated_at       datetime        
#
# Indexes
#
#  index_tr8n_translator_reports_on_translator_id    (translator_id) 
#
#++

class Tr8n::TranslatorReport < ActiveRecord::Base
  self.table_name = :tr8n_translator_reports
  
  attr_accessible :translator_id, :state, :object_id, :object_type, :reason, :comment
  attr_accessible :translator, :object

  belongs_to :translator, :class_name => "Tr8n::Translator"   
  belongs_to :object, :polymorphic => true

  def self.find_or_create(translator, object)
    report_for(translator, object) || create(:translator => translator, :object => object)
  end

  def self.report_for(translator, object)
    self.where("translator_id = ? and object_type = ? and object_id = ?", translator.id, object.class.name, object.id).first
  end
  
  def self.title_for(object)
    object.class.name.underscore.split('_').collect{|item| item.capitalize}.join(' ')
  end
  
  def self.default_reasons_for(object)
    if object.is_a?(Tr8n::TranslationKey)
      return ['Bad Grammar', 'Bad Tokens', 'Premature Lock', 'Other:']
    end

    if object.is_a?(Tr8n::Translation)
      return ['Inappropriate Language', 'Bad Tokens', 'Spam', 'Vandalism', 'Other:']
    end

    if object.is_a?(Tr8n::Translator)
      return ['Spammer', 'Vandalist', 'Bully', 'Other:']
    end

    if object.is_a?(Tr8n::LanguageForumMessage)
      return ['Inappropriate Language', 'Bad Tokens', 'Spam', 'Vandalism', 'Other:']
    end

    if object.is_a?(Tr8n::LanguageForumTopic)
      return ['Inappropriate Language', 'Bad Tokens', 'Spam', 'Vandalism', 'Other:']
    end

    if object.is_a?(Tr8n::TranslationKeyComment)
      return ['Inappropriate Language', 'Spam', 'Vandalism', 'Other:']
    end
    
    ['Inappropriate Language']
  end

  def self.submit(translator, object, reason, comment)
    report = find_or_create(translator, object)
    report.update_attributes(:reason => reason, :comment => comment)
    
    if object.is_a?(Tr8n::Translation) 
      object.vote!(translator, -100)
      submit(translator, object.translator, "bad translation #{object.id}", comment)
    elsif object.is_a?(Tr8n::LanguageForumMessage)
      submit(translator, object.translator, "bad message #{object.id}", comment)
    end
  end
  
end
