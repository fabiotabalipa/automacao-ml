resource "local_file" "auto_commit_sh" {
    filename = "${path.module}/files/auto_commit.sh"
    content = <<EOT
    git -C /home/ec2-user/${var.github_repo_name} add --all
    git -C /home/ec2-user/${var.github_repo_name} commit --quiet -m "Auto commit"
    git -C /home/ec2-user/${var.github_repo_name} push --quiet https://${var.github_access_token}@github.com/${var.github_user_name}/${var.github_repo_name}.git
    EOT
}

resource "local_file" "jupyter_cfg_gen_py" {
    filename = "${path.module}/files/jupyter_cfg_gen.py"
    content = <<-EOT
    import json

    from notebook.auth import passwd

    hashed = passwd('${var.team_pass}', 'sha1')

    cfg = {
        'NotebookApp': {
            'password': hashed,
            'token': '',
            'ip': '*'
        }
    }

    with open('jupyter_notebook_config.json', 'w') as f:
        json.dump(cfg, f)
    EOT
}

resource "local_file" "jupyter_service" {
    filename = "${path.module}/files/jupyter.service"
    content = <<EOT
    [Unit]
    Description=Jupyter Lab

    [Service]
    ExecStart=/home/ec2-user/anaconda3/bin/jupyter lab --port=8443 --config=/home/ec2-user/jupyter_notebook_config.json --no-browser
    User=ec2-user
    WorkingDirectory=/home/ec2-user/${var.github_repo_name}
    Restart=always
    RestartSec=10

    [Install]
    WantedBy=multi-user.target
    EOT
}
