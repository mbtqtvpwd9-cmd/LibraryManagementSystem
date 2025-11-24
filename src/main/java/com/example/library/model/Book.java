package com.example.library.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Entity
@Table(name = "books")
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "ISBN不能为空")
    @Size(max = 20, message = "ISBN长度不能超过20个字符")
    @Column(unique = true, nullable = false, length = 20)
    private String isbn;

    @NotBlank(message = "书名不能为空")
    @Size(max = 200, message = "书名长度不能超过200个字符")
    @Column(nullable = false, length = 200)
    private String title;

    @NotBlank(message = "作者不能为空")
    @Size(max = 100, message = "作者长度不能超过100个字符")
    @Column(nullable = false, length = 100)
    private String author;

    @NotBlank(message = "出版社不能为空")
    @Size(max = 100, message = "出版社长度不能超过100个字符")
    @Column(nullable = false, length = 100)
    private String publisher;

    @NotNull(message = "出版年份不能为空")
    @Column(nullable = false)
    private Integer publishYear;

    @NotNull(message = "价格不能为空")
    @Column(nullable = false)
    private Double price;

    @NotNull(message = "库存数量不能为空")
    @Column(nullable = false)
    private Integer stockQuantity;

    @Size(max = 500, message = "描述长度不能超过500个字符")
    private String description;

    public Book() {}

    public Book(String isbn, String title, String author, String publisher, 
                Integer publishYear, Double price, Integer stockQuantity, String description) {
        this.isbn = isbn;
        this.title = title;
        this.author = author;
        this.publisher = publisher;
        this.publishYear = publishYear;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.description = description;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }

    public Integer getPublishYear() { return publishYear; }
    public void setPublishYear(Integer publishYear) { this.publishYear = publishYear; }

    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }

    public Integer getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(Integer stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}