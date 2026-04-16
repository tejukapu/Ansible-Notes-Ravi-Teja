Ansible:

# Ansible is a tool we generally used for configuration purpose, previously system admins need to do configuration manually also devops engineers also need to crete different yaml files for defferent operating systems 
so in order to minimize all this and automate things we have ansible, inside ansible we have mainly two things one is control node and manage node

# USES
# for automating Network also we usally using Ansible
provisioning
configuration management
application deployment
orchestration

# Ansible is agentless in nature, which means you dont need install any software on the manage nodes.
for Automating linux and windows, ansible connects to managed nodes and pushes out small programs- called modules to them. this modules consistes of programs resource of the desired state of system. this can be executed by connecting to manage nodes through ssh and after work done it will remove once it finished task, this modules are will remain same so when ever we need to make changes it will do the task and come back.

# CONTROL NODE:  it is a vm where we can install ansible and pass instructions to perform tasks in target manage nodes, hear in ansible we dont have to install any agents to target manage nodes,
it is a agentless it automatically ssh to manage node and to the tasks.

# MANAGE NODE: this are the bunch of vm where we need to do configuration.

-------------------------------------------------------------------------------------------------
# for automatic ssh from control node to manage node we have to enable this thigs password and password less with providing key
# Passwordless Authentication

# EC2 Instances: ssh-copy-id -f "-o IdentityFile <PATH TO PEM FILE>" ubuntu@<INSTANCE-PUBLIC-IP>

ssh-copy-id: This is the command used to copy your public key to a remote machine.
-f: This flag forces the copying of keys, which can be useful if you have keys already set up and want to overwrite them.
"-o IdentityFile ": This option specifies the identity file (private key) to use for the connection. The -o flag passes this option to the underlying ssh command.
ubuntu@: This is the username (ubuntu) and the IP address of the remote server you want to access.

# Using Password

Go to the file /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
Update PasswordAuthentication yes
Restart SSH -> sudo systemctl restart ssh

# INVENTORY FILE:
this is the file that we holds the host details like ip to know control node which nodes to connect 

# We have two ways of passing commands to control node 1) Adhoc commands, 2)playbooks

Adhoc commands are used when we need to deal with less workload configurations and restarting like for doing onestep activities, Where as Playbooks are used to manage huge workloads like to install oracle databeses or configuring the infra created from terraform.
-----------------------------------------------------------------------
#PLAY BOOK: 
This is the CMD we use for running playbooks: ansible-playbook -i inventory <Adhoc command or Playbook.yml>
play book is a group of plays, inside the plays we have declare hosts: , remote: , Tasks where we have bunch of modules in it
modules means a type of script or action that we are trying to do in target vm like steps one module is to install apache, second module is to start like this modules a core thing that are actually doing the thigs.
#Module Ref: https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/index.html

---( it is defining Ansible yaml file)
- hosts: all (which target managed nodes need to connect with)
  become: true
  tasks:
    - name: Install apache httpd
      ansible.builtin.apt:("This are the modules that control nodes in target machine and exucute below steps by using python")
        name: apache2
        state: present (present or absent)
        update_cache: yes
    - name: Copy file with owner and permissions
      ansible.builtin.copy:
        src: index.html
        dest: /var/www/html
        owner: root
        group: root
        mode: '0644'

# Ansible Concepts: Playbook, Play, Modules, Tasks, and Collections

## Playbook
A **Playbook** is a YAML file that defines a series of actions to be executed on managed nodes. It contains one or more "plays" that map groups of hosts to roles.

### Example
```
---
- name: Update web servers
  hosts: webservers
  remote_user: root

  tasks:
  - name: Ensure apache is at the latest version
    ansible.builtin.yum:
      name: httpd
      state: latest

  - name: Write the apache config file
    ansible.builtin.template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf

- name: Update db servers
  hosts: databases
  remote_user: root

  tasks:
  - name: Ensure postgresql is at the latest version
    ansible.builtin.yum:
      name: postgresql
      state: latest

  - name: Ensure that postgresql is started
    ansible.builtin.service:
      name: postgresql
      state: started
```

## Play

A Play is a single, complete execution unit within a playbook. It specifies which hosts to target and what tasks to execute on those hosts. Plays are used to group related tasks and execute them in a specific order.

```
- name: Install and configure Nginx
  hosts: webservers
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
```

## Modules

Modules are the building blocks of Ansible tasks. They are small programs that perform a specific action on a managed node, such as installing a package, copying a file, or managing services.
Example

The apt module used in a task to install a package:

```
- name: Install Nginx
  apt:
    name: nginx
    state: present
```

## Tasks

Tasks are individual actions within a play that use modules to perform operations on managed nodes. Each task is executed in order and can include conditionals, loops, and handlers.
      
```
- name: Install Nginx
  apt:
    name: nginx
    state: present

- name: Start Nginx service
  service:
    name: nginx
    state: started
```

## Collections

Collections are a distribution format for Ansible content. They bundle together multiple roles, modules, plugins, and other Ansible artifacts. Collections make it easier to share and reuse Ansible content.
Example

A collection structure might look like this:

```
my_collection/
├── roles/
│   └── my_role/
│       └── tasks/
│           └── main.yml
├── plugins/
│   └── modules/
│       └── my_module.py
└── README.md
```

### Using a Collection

```
- name: Use a custom module from a collection
  community.general.my_module:
    option: value
```
----------------------------------------------------------------------------------
# Ansible Roles:
it is organized folder structure where it divide things in ansible playbook without mess to provide readibility and modularity reusability collaboration things, and also we can get roles in ansible galaxy section like a market place for kubernetes and different things roles.

you can download roles from ansible galaxy and there go to install section copy the command and run it in terminal, then you can find your installed roles on the section and use this command path

ls ~/("ref:tilt").ansible/roles

CMD: ansible-galaxy role init test. to create role in the ansible

An Ansible role is a reusable, self-contained unit of automation that is used to 
organize and manage tasks, variables, files, templates, and handlers in a structured way. 

Roles help to encapsulate and modularize the logic and configuration needed to manage 
a particular system or application component. 

This modular approach promotes reusability, maintainability, and consistency across different 
playbooks and environments.

## Key Components of an Ansible Role

### Tasks
The main list of actions that the role performs.

### Handlers
Tasks that are triggered by changes in other tasks, typically used for actions like restarting services.

### Files
Static files that need to be transferred to managed hosts.

### Templates
Jinja2 templates that can be rendered and transferred to managed hosts.

### Vars
Variables that are used within the role.

### Defaults
Default variables for the role, which can be overridden.

### Meta
Metadata about the role, including dependencies on other roles.

### Library
Custom modules or plugins used within the role.

### Module_defaults
Default module parameters for the role.

### Lookup_plugins
Custom lookup plugins for the role.

## Directory Structure of an Ansible Role

An Ansible role follows a specific directory structure:

```
<role_name>/
  ├── defaults/
  │   └── main.yml
  ├── files/
  ├── handlers/
  │   └── main.yml
  ├── meta/
  │   └── main.yml
  ├── tasks/
  │   └── main.yml
  ├── templates/
  ├── vars/
      └── main.yml
```

## Why Use Ansible Roles?

### Modularity
Roles allow you to break down complex playbooks into smaller, reusable components. 
Each role handles a specific part of the configuration or setup.

### Reusability
Once created, roles can be reused across different playbooks and projects. This saves time 
and effort in writing redundant code.

### Maintainability
By organizing related tasks into roles, it becomes easier to manage and maintain the code. 
Changes can be made in one place and applied consistently wherever the role is used.

### Readability
Roles make playbooks cleaner and easier to read by abstracting away the details into logically
named roles.

### Collaboration
Roles facilitate collaboration among team members by allowing them to work on different parts
of the infrastructure independently.

### Consistency
Using roles ensures that the same setup and configuration procedures are applied uniformly across
multiple environments, reducing the risk of configuration drift.

----------------------------------------------------------------------------- 
# Push your Ansible roles to Ansible Galaxy,   see it is a market place like docker hub we can download and publish ansible roles thats it LOL.

1. Make sure your role is structured correctly. The basic structure should look like this:

```
my_role/
├── defaults/
│   └── main.yml
├── files/
├── handlers/
│   └── main.yml
├── meta/
│   └── main.yml
├── tasks/
│   └── main.yml
├── templates/
├── tests/
│   ├── inventory
│   └── test.yml
└── vars/
    └── main.yml
```

2. Make sure ansible-galaxy CLI exists

```
ansible-galaxy --version
```

3. Push Your Role to GitHub

```
cd <role-name>
git init
git remote add origin <https://github.com/your_github_username/my_role.git>
git add .
git commit -m "Initial commit"
git push -u origin main
```

4. Import the Role to Ansible Galaxy

```
ansible-galaxy role import <your_github_username> <role-name>
```
---------------------------------------------------------------------------

Space lift is used to manage both terraform and ansible to gether maintaining security and maintaining sensitive credentials
order of execution.

For example we have terraform when ever we have changes in terraform code then automatically trigger things in ansible
inverntory file then automatically it have new hosts in inverntory then ansible will trigger things and do configuration.


















