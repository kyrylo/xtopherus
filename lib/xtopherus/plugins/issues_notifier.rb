module Xtopherus
  class IssuesNotifier
    include Cinch::Plugin

    # 12 minutes
    timer 720, method: :send_new_issue_notification

    listen_to :join

    def listen(m)
      send_new_issue_notification if m.user.nick == bot.nick
    end

    def send_new_issue_notification
      issues = Octokit.issues('pry/pry', page: 1).first(5)
      issues.each do |issue|
        if LatestIssue.find(html_url: issue['html_url']).nil?
          LatestIssue.create({
            login:    issue['user']['login'],
            title:    issue['title'],
            html_url: issue['html_url']})

          bot.channels.each { |chan|
            if (pr = issue['pull_request']['html_url'])
              Channel(chan).send(
                "[Pull Request] #{ issue['user']['login'] } has some code: " \
                "\"#{ issue['title'] }\". #{ pr }")
            else
              Channel(chan).send(
                "[Issue] #{ issue['user']['login'] } has a problem: " \
                "\"#{ issue['title'] }\". #{ issue['html_url'] }")
            end
          }
        end
      end
    end

  end
end
