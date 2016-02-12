# rubygems-issue-triage

This is the Rubygems webhook that manages the labels of any issue/pull_request when opening/closing.

When an issue/pull_request is opened it will set the specified label/s in <code>ISSUE_LABEL</code>
When an issue/pull_request is closed it will remove all the labels in that issue/pull_request

## Usage

Set the webhook to: <code>http://{your_host}/handle/label</code> in the github Webhooks & services options

Make sure you set the follow ENV variables:

| Variable                    | Data           |
| ----------------------------|:--------------:|
| ACCESS_TOKEN                | Github access token |
| REPO                        | Name of the repo you want to manage e.g user/my_repo |
| ISSUE_LABEL                 | Name of the label/s you want to add, can be multiple values separated by "," |
