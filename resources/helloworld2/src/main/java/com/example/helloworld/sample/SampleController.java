package com.example.helloworld.sample;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
@RequestMapping("sample")
public class SampleController {

    @RequestMapping(value = "create", params = "form")
    public String createForm(SampleForm form) {
        return "sample/createForm";
    }

    @RequestMapping(value = "create", params = "confirm", method = RequestMethod.POST)
    public String createConfirm(SampleForm form) {
        return "sample/createConfirm";
    }

    @RequestMapping(value = "create", method = RequestMethod.POST)
    public String create(SampleForm form) {
        return "redirect:/sample/create?complete";
    }

    @RequestMapping(value = "create", params = "complete", method = RequestMethod.GET)
    public String createComplete() {
        return "sample/createComplete";
    }

    @RequestMapping("hello")
    public String hello(@javax.validation.Valid SampleForm form,
            org.springframework.validation.BindingResult result) {
        System.out.println(form);
        return "sample/createForm";
    }
}
