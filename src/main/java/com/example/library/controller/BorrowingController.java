package com.example.library.controller;

import com.example.library.model.Borrowing;
import com.example.library.service.BorrowingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/borrowings")
@CrossOrigin(origins = "*")
public class BorrowingController {

    @Autowired
    private BorrowingService borrowingService;

    @GetMapping
    public ResponseEntity<Page<Borrowing>> getAllBorrowings(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<Borrowing> borrowings = borrowingService.findAllBorrowings(pageable);
        return ResponseEntity.ok(borrowings);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Page<Borrowing>> getBorrowingsByUser(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by("borrowDate").descending());
        Page<Borrowing> borrowings = borrowingService.findBorrowingsByUser(userId, pageable);
        return ResponseEntity.ok(borrowings);
    }

    @GetMapping("/book/{bookId}")
    public ResponseEntity<List<Borrowing>> getBorrowingsByBook(@PathVariable Long bookId) {
        List<Borrowing> borrowings = borrowingService.findBorrowingsByBook(bookId);
        return ResponseEntity.ok(borrowings);
    }

    @GetMapping("/overdue")
    public ResponseEntity<List<Borrowing>> getOverdueBorrowings() {
        List<Borrowing> borrowings = borrowingService.findOverdueBorrowings();
        return ResponseEntity.ok(borrowings);
    }

    @GetMapping("/active")
    public ResponseEntity<List<Borrowing>> getActiveBorrowings() {
        List<Borrowing> borrowings = borrowingService.findActiveBorrowings();
        return ResponseEntity.ok(borrowings);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'USER')")
    public ResponseEntity<Borrowing> borrowBook(@RequestBody Borrowing borrowing) {
        try {
            Borrowing savedBorrowing = borrowingService.borrowBook(borrowing);
            return ResponseEntity.ok(savedBorrowing);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PutMapping("/{id}/return")
    @PreAuthorize("hasAnyRole('ADMIN', 'USER')")
    public ResponseEntity<Borrowing> returnBook(@PathVariable Long id) {
        try {
            Borrowing borrowing = borrowingService.returnBook(id);
            return ResponseEntity.ok(borrowing);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/{id}/renew")
    @PreAuthorize("hasAnyRole('ADMIN', 'USER')")
    public ResponseEntity<Borrowing> renewBook(@PathVariable Long id) {
        try {
            Borrowing borrowing = borrowingService.renewBook(id);
            return ResponseEntity.ok(borrowing);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/stats")
    public ResponseEntity<?> getBorrowingStats() {
        var stats = borrowingService.getBorrowingStats();
        return ResponseEntity.ok(stats);
    }
}