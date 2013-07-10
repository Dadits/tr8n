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
#-- Tr8n::LanguageForumMessage Schema Information
#
# Table name: tr8n_language_forum_messages
#
#  id                         INTEGER     not null, primary key
#  language_id                integer     not null
#  language_forum_topic_id    integer     not null
#  translator_id              integer     not null
#  message                    text        not null
#  created_at                 datetime    
#  updated_at                 datetime    
#
# Indexes
#
#  tr8n_forum_msgs_lang_id_topic_id    (language_id, language_forum_topic_id) 
#  tr8n_forums_msgs_translator_id      (translator_id) 
#  tr8n_forum_msgs_lang_id             (language_id) 
#
#++

class Tr8n::LanguageForumMessage < ActiveRecord::Base
  set_table_name :tr8n_language_forum_messages

  attr_accessible :language_id, :language_forum_topic_id, :translator_id, :message
  attr_accessible :language, :translator, :language_forum_topic

  belongs_to :language,               :class_name => "Tr8n::Language"  
  belongs_to :translator,             :class_name => "Tr8n::Translator"  
  belongs_to :language_forum_topic,   :class_name => "Tr8n::LanguageForumTopic"
  
  has_many :language_forum_abuse_reports, :class_name => "Tr8n::LanguageForumAbuseReport", :dependent => :destroy

  alias :topic :language_forum_topic

  def submit_abuse_report(reporter)
    report = Tr8n::LanguageForumAbuseReport.where("language_forum_message_id = ? and translator_id = ?", self.id, reporter.id).first
    report ||= Tr8n::LanguageForumAbuseReport.create(:language_forum_message => self, :translator => reporter, :language => language)
    translator.update_attributes(:reported => true)
    report
  end
  
  def toHTML
    return "" unless message
    ERB::Util.html_escape(message).gsub("\n", "<br>")
  end
end
