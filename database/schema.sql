-- Udicon Trading: empty database schema for MySQL 8.0+
-- Import once into an empty database; no operational records are included.

SET NAMES utf8mb4;
SET @UDICON_OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `activity_log` (
  `logID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `details` varchar(500) DEFAULT NULL,
  `logDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`logID`),
  KEY `userID` (`userID`),
  CONSTRAINT `activity_log_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `backup` (
  `backupID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `backupDate` datetime NOT NULL,
  `fileName` varchar(100) NOT NULL,
  `backupType` enum('Manual','Scheduled','Incremental') NOT NULL,
  PRIMARY KEY (`backupID`),
  KEY `userID` (`userID`),
  CONSTRAINT `backup_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `inventory_record` (
  `inventoryID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `productID` int DEFAULT NULL,
  `supplierID` int DEFAULT NULL,
  `actionType` enum('Add','Edit','Archive','Supplier Add','Supplier Edit','Supplier Archive','Damaged goods','Lost / Stolen','Inventory count correction','Stock Adjustment') NOT NULL,
  `quantityChange` int NOT NULL,
  `details` varchar(500) DEFAULT NULL,
  `inventoryDate` datetime NOT NULL,
  PRIMARY KEY (`inventoryID`),
  KEY `userID` (`userID`),
  KEY `productID` (`productID`),
  KEY `supplierID` (`supplierID`),
  CONSTRAINT `inventory_record_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`),
  CONSTRAINT `inventory_record_ibfk_2` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`),
  CONSTRAINT `inventory_record_ibfk_3` FOREIGN KEY (`supplierID`) REFERENCES `supplier` (`supplierID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `payment_log` (
  `paymentID` int NOT NULL AUTO_INCREMENT,
  `transactionCode` varchar(50) NOT NULL,
  `dueDate` date DEFAULT NULL,
  `amountDue` decimal(12,2) DEFAULT '0.00',
  `cashAmount` decimal(12,2) DEFAULT '0.00',
  `digitalAmount` decimal(12,2) DEFAULT '0.00',
  `paymentDate` datetime DEFAULT NULL,
  `paymentMethod` varchar(50) DEFAULT NULL,
  `referenceNumber` varchar(100) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Scheduled',
  `paymentType` varchar(20) DEFAULT 'Installment',
  PRIMARY KEY (`paymentID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `product` (
  `productID` int NOT NULL AUTO_INCREMENT,
  `productName` varchar(250) NOT NULL,
  `barcode` varchar(50) NOT NULL,
  `category` varchar(50) NOT NULL,
  `stockQuantity` int NOT NULL,
  `initialPrice` decimal(10,2) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `productDescription` varchar(250) DEFAULT NULL,
  `imagePath` varchar(255) DEFAULT NULL,
  `isActive` tinyint DEFAULT '1',
  `lowStockThreshold` int NOT NULL DEFAULT '10',
  `variantOptions` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`productID`),
  UNIQUE KEY `barcode` (`barcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `purchase_item` (
  `purchaseItemID` int NOT NULL AUTO_INCREMENT,
  `orderID` int NOT NULL,
  `productID` int NOT NULL,
  `quantity` int NOT NULL,
  `unitCost` decimal(10,2) NOT NULL,
  `receivedQty` int NOT NULL DEFAULT '0',
  `defectiveQty` int NOT NULL DEFAULT '0',
  `leadTimeDays` int DEFAULT NULL,
  PRIMARY KEY (`purchaseItemID`),
  KEY `orderID` (`orderID`),
  KEY `productID` (`productID`),
  CONSTRAINT `purchase_item_ibfk_1` FOREIGN KEY (`orderID`) REFERENCES `purchase_order` (`orderID`),
  CONSTRAINT `purchase_item_ibfk_2` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `purchase_order` (
  `orderID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `supplierID` int NOT NULL,
  `orderDateTime` datetime NOT NULL,
  `status` enum('To Order','Pending Order','Partially Completed','Completed','Cancelled') NOT NULL DEFAULT 'To Order',
  `contact` varchar(100) DEFAULT NULL,
  `shipmentInfo` varchar(255) DEFAULT NULL,
  `paymentStatus` enum('Pending','Partially Paid','Completed') DEFAULT 'Pending',
  `paymentMethod` varchar(50) DEFAULT NULL,
  `paymentReference` varchar(100) DEFAULT NULL,
  `paymentDate` datetime DEFAULT NULL,
  `amountPaid` decimal(10,2) DEFAULT NULL,
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  `shipToAddress` text,
  `termsOfPayment` varchar(100) DEFAULT NULL,
  `receiveDate` datetime DEFAULT NULL,
  `dueDate` date DEFAULT NULL,
  PRIMARY KEY (`orderID`),
  KEY `userID` (`userID`),
  KEY `supplierID` (`supplierID`),
  CONSTRAINT `purchase_order_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`),
  CONSTRAINT `purchase_order_ibfk_2` FOREIGN KEY (`supplierID`) REFERENCES `supplier` (`supplierID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `report` (
  `reportID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `reportType` enum('Sales Performance','User logs','Stock alerts') NOT NULL,
  `generateDate` datetime NOT NULL,
  PRIMARY KEY (`reportID`),
  KEY `userID` (`userID`),
  CONSTRAINT `report_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sales_item` (
  `salesItemID` int NOT NULL AUTO_INCREMENT,
  `transactionID` int NOT NULL,
  `productID` int NOT NULL,
  `quantity` int NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `productName` varchar(250) DEFAULT NULL,
  `unitPrice` decimal(10,2) DEFAULT NULL,
  `returnStatus` enum('NONE','RESELLABLE','DEFECTIVE') DEFAULT 'NONE',
  PRIMARY KEY (`salesItemID`),
  KEY `transactionID` (`transactionID`),
  KEY `productID` (`productID`),
  CONSTRAINT `sales_item_ibfk_1` FOREIGN KEY (`transactionID`) REFERENCES `sales_transaction` (`transactionID`),
  CONSTRAINT `sales_item_ibfk_2` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sales_transaction` (
  `transactionID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `transDateTime` datetime NOT NULL,
  `totalAmount` decimal(10,2) NOT NULL,
  `paymentMethod` varchar(50) NOT NULL,
  `transactionCode` varchar(100) DEFAULT NULL,
  `paymentStatus` enum('Paid','Unpaid','Partial','Refunded','Exchanged') DEFAULT 'Paid',
  `discountAmount` decimal(10,2) DEFAULT '0.00',
  `cashReceived` decimal(10,2) DEFAULT '0.00',
  `digitalAmount` decimal(10,2) DEFAULT '0.00',
  `referenceNumber` varchar(100) DEFAULT NULL,
  `customerName` varchar(255) DEFAULT NULL,
  `contactInfo` varchar(255) DEFAULT NULL,
  `address` text,
  `dueDate` date DEFAULT NULL,
  `refundOffset` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`transactionID`),
  UNIQUE KEY `transactionCode` (`transactionCode`),
  KEY `userID` (`userID`),
  CONSTRAINT `sales_transaction_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `supplier` (
  `supplierID` int NOT NULL AUTO_INCREMENT,
  `supplierName` varchar(100) NOT NULL,
  `contactNumber` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `address` varchar(250) DEFAULT NULL,
  `isActive` tinyint DEFAULT '1',
  `termsOfPayment` varchar(255) DEFAULT 'COD',
  PRIMARY KEY (`supplierID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `supplier_products` (
  `supplierID` int NOT NULL,
  `productID` int NOT NULL,
  PRIMARY KEY (`supplierID`,`productID`),
  KEY `productID` (`productID`),
  CONSTRAINT `supplier_products_ibfk_1` FOREIGN KEY (`supplierID`) REFERENCES `supplier` (`supplierID`) ON DELETE CASCADE,
  CONSTRAINT `supplier_products_ibfk_2` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `users` (
  `userID` int NOT NULL AUTO_INCREMENT,
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `userPassword` varchar(255) NOT NULL,
  `role` set('Admin','SalesStaff','InventoryStaff') NOT NULL,
  `contactInfo` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `isActive` tinyint(1) DEFAULT '1',
  `security_question` varchar(255) DEFAULT NULL,
  `security_answer` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`userID`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = @UDICON_OLD_FOREIGN_KEY_CHECKS;
