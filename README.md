## ansible_docker_container

Here we are running ansible in docker container. It is useful in cases where there are do many developers in team. And we would like to achieve always same reproduciable environment for everyone. Then this comes into play.

To use this container:

> docker run  -v “$(pwd)”:/ansible/playbooks megha910825/ansible_docker_container test-playbook.yml -i inventory_file_name

or to run ansible adhoc commands

> docker run megha910825/ansible_docker_container ansible --version
