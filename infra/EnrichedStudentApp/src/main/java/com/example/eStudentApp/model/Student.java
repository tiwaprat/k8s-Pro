package com.example.eStudentApp.model;

import jakarta.persistence.*;

@Entity
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private int marks;

    // Constructors
    public Student() {}

    public Student(String name, int marks) {
        this.name = name;
        this.marks = marks;
    }

    // Getters & Setters
    public Long getId() { return id; }

    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }

    public void setName(String name) { this.name = name; }

    public int getMarks() { return marks; }

    public void setMarks(int marks) { this.marks = marks; }
}

