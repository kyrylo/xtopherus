module Xtopherus
  class IssuesNotifier
    include Cinch::Plugin

    # 12 minutes
    timer 30, method: :send_new_issue_notification

    listen_to :join

    def listen(m)
      send_new_issue_notification if m.user.nick == bot.nick
    end

    def send_new_issue_notification
      issue = Octokit.issues('pry/test', page: 1).first
      params =  {
        login:    issue['user']['login'],
        title:    issue['title'],
        html_url: issue['html_url']
      }
      latest_issue = (LatestIssue.last || LatestIssue.create(params))

      if latest_issue.html_url != issue.html_url
        latest_issue.update(params)
        bot.channels.each { |chan|
          Channel(chan).send(
            "#{ issue['user']['login'] } opened a new issue: " \
            "\"#{ issue['title'] }\". #{ issue['html_url'] }") }
      end
    end

  end
end
