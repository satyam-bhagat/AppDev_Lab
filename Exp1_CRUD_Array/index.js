// CRUD program in JavaScript (Node.js)
// Run: node crud.js

const readline = require("readline");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

let items = []; // our array

function showMenu() {
  console.log("\n--- CRUD Menu ---");
  console.log("1. Create");
  console.log("2. Read");
  console.log("3. Update");
  console.log("4. Delete");
  console.log("5. Exit");

  rl.question("Choose an option: ", (choice) => {
    switch (choice) {
      case "1": createItem(); break;
      case "2": readItems(); break;
      case "3": updateItem(); break;
      case "4": deleteItem(); break;
      case "5": console.log("Exiting..."); rl.close(); return;
      default: console.log("Invalid choice."); showMenu();
    }
  });
}

function createItem() {
  rl.question("Enter item to add: ", (newItem) => {
    items.push(newItem);
    console.log(`Item "${newItem}" added.`);
    showMenu();
  });
}

function readItems() {
  console.log("Current items:", items.length > 0 ? items : "No items yet.");
  showMenu();
}

function updateItem() {
  rl.question("Enter index to update: ", (index) => {
    index = Number(index);
    if (index >= 0 && index < items.length) {
      rl.question("Enter new value: ", (newValue) => {
        console.log(`Item "${items[index]}" updated to "${newValue}".`);
        items[index] = newValue;
        showMenu();
      });
    } else {
      console.log("Invalid index.");
      showMenu();
    }
  });
}

function deleteItem() {
  rl.question("Enter index to delete: ", (index) => {
    index = Number(index);
    if (index >= 0 && index < items.length) {
      console.log(`Item "${items[index]}" deleted.`);
      items.splice(index, 1);
    } else {
      console.log("Invalid index.");
    }
    showMenu();
  });
}

// start program
showMenu();
