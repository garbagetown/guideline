package com.example.helloworld.echo;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("echo")
public class EchoController {

    @ModelAttribute // (1)
    public EchoForm setUpEchoForm() {
        EchoForm form = new EchoForm();
        return form;
    }

    @RequestMapping // (2)
    public String index(Model model) {
        return "echo/index"; // (4)
    }

    @RequestMapping("hello") // (5)
    public String hello(EchoForm form, Model model) {// (3)
        model.addAttribute("name", form.getName()); // (6)
        return "echo/hello";
    }
}
