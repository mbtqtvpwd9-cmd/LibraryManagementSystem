package com.example.library.service;

import com.example.library.model.Borrowing;
import com.example.library.model.Book;
import com.example.library.model.User;
import com.example.library.repository.BorrowingRepository;
import com.example.library.repository.BookRepository;
import com.example.library.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@Transactional
public class BorrowingService {

    @Autowired
    private BorrowingRepository borrowingRepository;

    @Autowired
    private BookRepository bookRepository;

    @Autowired
    private UserRepository userRepository;

    public Page<Borrowing> findAllBorrowings(Pageable pageable) {
        return borrowingRepository.findAll(pageable);
    }

    public Page<Borrowing> findBorrowingsByUser(Long userId, Pageable pageable) {
        return borrowingRepository.findByUserId(userId, pageable);
    }

    public List<Borrowing> findBorrowingsByBook(Long bookId) {
        return borrowingRepository.findByBookId(bookId);
    }

    public List<Borrowing> findOverdueBorrowings() {
        return borrowingRepository.findOverdueBorrowings();
    }

    public List<Borrowing> findActiveBorrowings() {
        return borrowingRepository.findByStatus("BORROWED");
    }

    public Borrowing borrowBook(Borrowing borrowing) {
        Book book = borrowing.getBook();
        if (book.getStockQuantity() <= 0) {
            throw new RuntimeException("图书库存不足");
        }

        book.setStockQuantity(book.getStockQuantity() - 1);
        bookRepository.save(book);

        borrowing.setBorrowDate(LocalDateTime.now());
        borrowing.setDueDate(LocalDateTime.now().plusDays(30));
        borrowing.setStatus("BORROWED");

        return borrowingRepository.save(borrowing);
    }

    public Borrowing returnBook(Long borrowingId) {
        Optional<Borrowing> borrowingOpt = borrowingRepository.findById(borrowingId);
        if (!borrowingOpt.isPresent()) {
            throw new RuntimeException("借阅记录不存在");
        }

        Borrowing borrowing = borrowingOpt.get();
        if (!"BORROWED".equals(borrowing.getStatus())) {
            throw new RuntimeException("该图书已经归还");
        }

        Book book = borrowing.getBook();
        book.setStockQuantity(book.getStockQuantity() + 1);
        bookRepository.save(book);

        borrowing.setReturnDate(LocalDateTime.now());
        borrowing.setStatus("RETURNED");

        return borrowingRepository.save(borrowing);
    }

    public Borrowing renewBook(Long borrowingId) {
        Optional<Borrowing> borrowingOpt = borrowingRepository.findById(borrowingId);
        if (!borrowingOpt.isPresent()) {
            throw new RuntimeException("借阅记录不存在");
        }

        Borrowing borrowing = borrowingOpt.get();
        if (!"BORROWED".equals(borrowing.getStatus())) {
            throw new RuntimeException("该图书已经归还，无法续借");
        }

        borrowing.setDueDate(borrowing.getDueDate().plusDays(15));
        return borrowingRepository.save(borrowing);
    }

    public Map<String, Object> getBorrowingStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalBorrowings", borrowingRepository.count());
        stats.put("activeBorrowings", borrowingRepository.findByStatus("BORROWED").size());
        stats.put("overdueBorrowings", borrowingRepository.findOverdueBorrowings().size());
        stats.put("returnedBorrowings", borrowingRepository.findByStatus("RETURNED").size());
        return stats;
    }
}