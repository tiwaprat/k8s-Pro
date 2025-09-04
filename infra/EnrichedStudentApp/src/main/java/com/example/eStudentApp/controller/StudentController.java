package com.example.eStudentApp.controller;

import com.example.eStudentApp.model.Student;
import com.example.eStudentApp.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class StudentController {

    @Autowired
    private StudentRepository repository;

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("students", repository.findAll());
        return "index";
    }

    @PostMapping("/add")
    public String addStudent(@RequestParam String name, @RequestParam int marks) {
        Student student = new Student(name, marks);
        repository.save(student);
        return "redirect:/";
    }

    @GetMapping("/delete/{id}")
    public String deleteStudent(@PathVariable Long id) {
        repository.deleteById(id);
        return "redirect:/";
    }
}

