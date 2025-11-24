package com.example.library.config;

import com.example.library.model.Book;
import com.example.library.service.BookService;
import com.example.library.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Random;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private BookService bookService;

    @Autowired
    private UserService userService;

    @Override
    public void run(String... args) throws Exception {
        // 创建默认用户
        userService.createDefaultAdmin();
        userService.createDefaultReader();

        // 如果数据库中没有图书，则创建1000条虚拟图书数据
        if (bookService.getTotalBookCount() == 0) {
            createSampleBooks();
        }
    }

    private void createSampleBooks() {
        String[] titles = {
            "Java编程思想", "Spring实战", "Python数据分析", "算法导论", "深度学习",
            "机器学习实战", "数据结构与算法", "设计模式", "代码整洁之道", "重构",
            "微服务架构设计", "分布式系统原理", "数据库系统概念", "计算机网络", "操作系统概念",
            "编译原理", "软件工程", "人工智能导论", "大数据技术", "云计算架构",
            "Web前端开发", "Vue.js实战", "React开发实战", "Angular权威指南", "Node.js实战",
            "Docker容器技术", "Kubernetes权威指南", "DevOps实践", "持续集成与部署", "敏捷软件开发"
        };

        String[] authors = {
            "Bruce Eckel", "Craig Walls", "Wes McKinney", "Thomas Cormen", "Ian Goodfellow",
            "Peter Harrington", "Robert Sedgewick", "Erich Gamma", "Robert Martin", "Martin Fowler",
            "Chris Richardson", "Leslie Lamport", "Abraham Silberschatz", "Andrew Tanenbaum", "Abraham Silberschatz",
            "Alfred Aho", "Ian Sommerville", "Stuart Russell", "Viktor Mayer-Schönberger", "Thomas Erl",
            "Eric Freeman", "Evan You", "Mark Tielens", "Adam Freeman", "Mikola Lysenko",
            "James Turnbull", "Kelsey Hightower", "Gene Kim", "Paul Duvall", "Robert Martin"
        };

        String[] publishers = {
            "机械工业出版社", "电子工业出版社", "清华大学出版社", "人民邮电出版社", "中国电力出版社",
            "O'Reilly Media", "Addison-Wesley", "Manning Publications", "Packt Publishing", "Apress",
            "Wiley", "McGraw-Hill", "Pearson", "Cambridge University Press", "MIT Press"
        };

        Random random = new Random();

        for (int i = 1; i <= 1000; i++) {
            String title = titles[random.nextInt(titles.length)] + " 第" + ((i % 10) + 1) + "版";
            String author = authors[random.nextInt(authors.length)];
            String publisher = publishers[random.nextInt(publishers.length)];
            String isbn = "978-" + String.format("%04d", random.nextInt(10000)) + "-" + 
                         String.format("%04d", random.nextInt(10000)) + "-" + random.nextInt(10);
            int publishYear = 2015 + random.nextInt(9);
            double price = 29.99 + random.nextDouble() * 170.01;
            int stockQuantity = random.nextInt(100);
            String description = "这是一本关于" + title + "的优秀图书，适合初学者和进阶读者阅读。";

            Book book = new Book(isbn, title, author, publisher, publishYear, price, stockQuantity, description);
            bookService.saveBook(book);

            if (i % 100 == 0) {
                System.out.println("已创建 " + i + " 本图书数据");
            }
        }

        System.out.println("成功创建1000本虚拟图书数据！");
    }
}