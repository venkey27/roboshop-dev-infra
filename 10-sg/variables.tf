variable "project" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "sg_names" {
    type = list
    default = [
        "mongodb", "redis", "mysql", "rabbitmq",               # for  database
        "catalogue", "user", "cart", "shipping", "payment",    # for backend
        "backend_alb",   
        "frontend",
        "frontend_alb",    # frontend_alb = _ is for programming 
        "bastion"          # roboshop-dev = - is for human readability
    ]
}

