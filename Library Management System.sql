create database Library_management_systems;
 use Library_management_systems; 
 -- Table: publisher 
 CREATE TABLE publisher ( 
 publisher_PublisherName VARCHAR(255) PRIMARY KEY, 
 publisher_PublisherAddress TEXT, 
 publisher_PublisherPhone VARCHAR(15) 
 );
CREATE TABLE book (
    book_BookID INT PRIMARY KEY,
    book_Title VARCHAR(255),
    book_PublisherName VARCHAR(255),
    FOREIGN KEY (book_PublisherName) REFERENCES publisher(publisher_PublisherName)
);
CREATE TABLE book_authors (
    book_authors_AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    book_authors_BookID INT,
    book_authors_AuthorName VARCHAR(255),
    FOREIGN KEY (book_authors_BookID) REFERENCES book(book_BookID)
);
CREATE TABLE library_branch (
    library_branch_BranchID INT PRIMARY KEY AUTO_INCREMENT,
    library_branch_BranchName VARCHAR(255),
    library_branch_BranchAddress TEXT
);
CREATE TABLE book_copies (
    book_copies_CopiesID INT PRIMARY KEY AUTO_INCREMENT,
    book_copies_BookID INT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies INT,
    FOREIGN KEY (book_copies_BookID) REFERENCES book(book_BookID),
    FOREIGN KEY (book_copies_BranchID) REFERENCES library_branch(library_branch_BranchID)
);
CREATE TABLE borrower (
    borrower_CardNo INT PRIMARY KEY,
    borrower_BorrowerName VARCHAR(255),
    borrower_BorrowerAddress TEXT,
    borrower_BorrowerPhone VARCHAR(15)
);
CREATE TABLE book_loans (
    book_loans_LoansID INT PRIMARY KEY AUTO_INCREMENT,
    book_loans_BookID INT,
    book_loans_BranchID INT,
    book_loans_CardNo INT,
    book_loans_DateOut DATE,
    book_loans_DueDate DATE,
    FOREIGN KEY (book_loans_BookID) REFERENCES book(book_BookID),
    FOREIGN KEY (book_loans_BranchID) REFERENCES library_branch(library_branch_BranchID),
    FOREIGN KEY (book_loans_CardNo) REFERENCES borrower(borrower_CardNo)
);

-- 1) How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
select book_copies_No_Of_Copies from book_copies
where
book_copies_BookID=(select book_BookID from book where book_Title='The Lost Tribe')
and
book_copies_BranchID=(select library_branch_BranchID from library_branch where library_branch_BranchName="Sharpstown");

-- 2) How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select book_copies_BranchID, book_copies_No_Of_Copies from book_copies
where
book_copies_BookID=(select book_BookID from book where book_Title='The Lost Tribe');

-- 3) Retrieve the names of all borrowers who do not have any books checked out.
select borrower_CardNo, borrower_BorrowerName from borrower
where borrower_CardNo not in (select distinct book_loans_CardNo from book_loans);

/* 4) For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18,
retrieve the book title, the borrower's name, and the borrower's address.*/
select b.book_Title,c.borrower_BorrowerName,c.borrower_BorrowerAddress from book b
join book_loans d on d.book_loans_BookID=b.book_BookID
join borrower c on c.borrower_CardNo=d.book_loans_CardNo
join library_branch e on e.library_branch_BranchID=d.book_loans_BranchID
where e.library_branch_BranchName='Sharpstown' and d.book_loans_DueDate='0002-03-18';

-- 5) For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
select l.library_branch_BranchName, count(b.book_loans_BookID) as total_number_of_books_loaned_out from library_branch l
join book_loans b on l.library_branch_BranchID=b.book_loans_BranchID group by b.book_loans_BranchID;

-- 6) Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
with ctel as (
select b.borrower_BorrowerName,b.borrower_BorrowerAddress,count(l.book_loans_BookID) as number_of_books_checked_out from borrower b
join book_loans l on b.borrower_CardNo=l.book_loans_CardNo group by b.borrower_CardNo)
select * from ctel where number_of_books_checked_out>5;

/* 7) For each book authored by "Stephen King", retrieve the title and the number of copies owned by the
library branch whose name is "Central". */
select b.book_Title,c.book_copies_No_Of_Copies as no_of_copies from book b
join book_authors a on b.book_BookID=a.book_authors_BookID
join book_copies c on c.book_copies_BookID=a.book_authors_BookID
join library_branch l on l.library_branch_BranchID=book_copies_BranchID
where a.book_authors_AuthorName='Stephen King' and l.library_branch_BranchName="Central";
