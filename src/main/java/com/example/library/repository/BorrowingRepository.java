package com.example.library.repository;

import com.example.library.model.Borrowing;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface BorrowingRepository extends JpaRepository<Borrowing, Long> {

    Page<Borrowing> findByUserId(Long userId, Pageable pageable);

    List<Borrowing> findByBookId(Long bookId);

    List<Borrowing> findByStatus(String status);

    @Query("SELECT b FROM Borrowing b WHERE b.status = 'BORROWED' AND b.dueDate < :now")
    List<Borrowing> findOverdueBorrowings(@Param("now") LocalDateTime now);

    @Query("SELECT b FROM Borrowing b WHERE b.status = 'BORROWED' AND b.dueDate < :now")
    List<Borrowing> findOverdueBorrowings();
}