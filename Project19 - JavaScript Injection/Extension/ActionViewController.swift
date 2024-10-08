//
//  ActionViewController.swift
//  Extension
//
//  Created by Stefan Storm on 2024/10/06.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController, ScriptViewControllerDelegate{
    
    var selectedValue: String?

    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    var defaults = UserDefaults.standard
    var selectedScript = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let done = UIBarButtonItem(title: "Execute", style: .plain, target: self, action: #selector(done))
        let add = UIBarButtonItem(title: "Sample", style: .plain, target: self, action: #selector(add))
        let save = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveScript))
        let load = UIBarButtonItem(title: "Load", style: .plain, target: self, action: #selector(loadScript))
        
        navigationItem.rightBarButtonItems = [done, add]
        navigationItem.leftBarButtonItems = [save,load]
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.description) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    print(itemDictionary)
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                }
            }
        }
    
    }
    
    
    @objc func saveScript(){
        guard checkTextPresent() else {return}
        
        var scriptDict = defaults.dictionary(forKey: "scriptDict") as? [String: String] ?? [String: String]()

        let ac = UIAlertController(title: "Save script as", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let addAction = UIAlertAction(title: "Save", style: .default){ [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else {return}
            scriptDict[newName] = self?.script.text
            print(scriptDict)
            
            self?.defaults.setValue(scriptDict, forKey: "scriptDict")
        }
  
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(addAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    
    @objc func loadScript(){
        let vc = ScriptViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @objc func add(){
        let ac = UIAlertController(title: "Sample Scripts", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Page Details", style: .default, handler: addPreset))
        ac.addAction(UIAlertAction(title: "Display Images", style: .default, handler: addPreset))
        ac.addAction(UIAlertAction(title: "Play Snake", style: .default, handler: addPreset))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    
    @objc func adjustForKeyboard(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        script.scrollIndicatorInsets = script.contentInset

        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    

    @IBAction func done() {
        guard checkTextPresent() else {return}
        
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text ?? ""]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.description as String)
        item.attachments = [customJavaScript]

        extensionContext?.completeRequest(returningItems: [item])
    }
    
    
    func checkTextPresent() -> Bool{
        if script.hasText {
            return true
        }else {
            let ac = UIAlertController(title: "Textfield empty!", message: "Please add a script", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return false
        }
    }
    
    
    func didSelectItem(_ selectedItem: String) {
        self.selectedValue = selectedItem
        script.text = self.selectedValue
    }
    
    
    func addPreset(_ action: UIAlertAction){
        guard let actionTitle = action.title else {return}
        
        switch actionTitle{
        case "Page Details":
            script.text = """
            alert(
                "Title: " + document.title +
                "\\nURL: " + document.URL +
                "\\nHostname: " + location.hostname +
                "\\nPathname: " + location.pathname +
                "\\nProtocol: " + location.protocol +
                "\\nLast Modified: " + document.lastModified +
                "\\nScreen Dimensions: " + screen.width + "x" + screen.height
            );
            """
        case "Display Images":
            script.text = """
                // Create a modal to display the main image
                var modal = document.createElement('div');
                modal.style.position = 'fixed';
                modal.style.top = '50%';
                modal.style.left = '50%';
                modal.style.transform = 'translate(-50%, -50%)';
                modal.style.backgroundColor = 'white';
                modal.style.padding = '20px';
                modal.style.border = '2px solid black';
                modal.style.zIndex = '10000';
                modal.style.maxWidth = '90%'; // Ensure it fits on mobile
                modal.style.maxHeight = '80%'; // Restrict height for mobile
                modal.style.overflowY = 'scroll';
                
                // Create a close button
                var closeBtn = document.createElement('button');
                closeBtn.innerText = 'Close';
                closeBtn.style.marginTop = '10px';
                closeBtn.onclick = function() { document.body.removeChild(modal); };
                modal.appendChild(closeBtn);
                
                // Select the main image (assuming it's the first image on the page)
                var mainImage = document.querySelector('img'); // Or use document.querySelector('.header-img') for a specific class
                
                // Check if the image exists and display it
                if (mainImage) {
                    var img = document.createElement('img');
                    img.src = mainImage.src;
                    img.alt = mainImage.alt;
                    img.style.width = '100%'; // Ensure the image fits within the modal
                    img.style.maxWidth = '100%'; // Mobile-friendly
                
                    var imgTitle = document.createElement('h2');
                    imgTitle.innerText = "Image Title: " + (mainImage.alt || 'No title available'); // Use alt or a fallback message
                
                    modal.appendChild(imgTitle);
                    modal.appendChild(img);
                } else {
                    modal.innerHTML = "<p>No main image found on this page.</p>";
                }
                
                // Append the modal to the body
                document.body.appendChild(modal);
                """

        default:
                  script.text = """
      // Create a modal for the Snake Game
      var modal = document.createElement('div');
      modal.style.position = 'fixed';
      modal.style.top = '50%';
      modal.style.left = '50%';
      modal.style.transform = 'translate(-50%, -50%)';
      modal.style.backgroundColor = 'white';
      modal.style.padding = '20px';
      modal.style.border = '2px solid black';
      modal.style.zIndex = '10000';
      modal.style.maxWidth = '90%'; // Mobile-friendly
      modal.style.maxHeight = '80%'; // Mobile-friendly
      modal.style.textAlign = 'center';
      document.body.appendChild(modal);
      
      // Create a canvas for the snake game
      var canvas = document.createElement('canvas');
      canvas.width = 300;
      canvas.height = 300;
      modal.appendChild(canvas);
      var ctx = canvas.getContext('2d');
      
      // Initialize the game variables
      var snake = [{x: 50, y: 50}, {x: 40, y: 50}, {x: 30, y: 50}];
      var direction = 'RIGHT';
      var food = {x: 80, y: 80};
      var score = 0;
      var gameInterval;
      var gameOver = false;
      var touchStart = null;
      
      // Draw the snake
      function drawSnake() {
          ctx.clearRect(0, 0, canvas.width, canvas.height);
          ctx.fillStyle = 'green';
          for (var i = 0; i < snake.length; i++) {
              ctx.fillRect(snake[i].x, snake[i].y, 10, 10);
          }
      }
      
      // Draw the food
      function drawFood() {
          ctx.fillStyle = 'red';
          ctx.fillRect(food.x, food.y, 10, 10);
      }
      
      // Update the game state
      function updateGame() {
          if (gameOver) {
              ctx.fillStyle = 'black';
              ctx.font = '20px Arial';
              ctx.fillText('Game Over! Score: ' + score, 60, canvas.height / 2);
              clearInterval(gameInterval);
              return;
          }
      
          var newHead = {x: snake[0].x, y: snake[0].y};
      
          if (direction === 'UP') newHead.y -= 10;
          if (direction === 'DOWN') newHead.y += 10;
          if (direction === 'LEFT') newHead.x -= 10;
          if (direction === 'RIGHT') newHead.x += 10;
      
          snake.unshift(newHead);
      
          // Check for collisions with the food
          if (newHead.x === food.x && newHead.y === food.y) {
              score += 10;
              food = {x: Math.floor(Math.random() * (canvas.width / 10)) * 10, y: Math.floor(Math.random() * (canvas.height / 10)) * 10};
          } else {
              snake.pop();
          }
      
          // Check for collisions with walls or itself
          if (newHead.x < 0 || newHead.x >= canvas.width || newHead.y < 0 || newHead.y >= canvas.height || isSnakeCollision(newHead)) {
              gameOver = true;
          }
      
          drawSnake();
          drawFood();
          ctx.fillStyle = 'black';
          ctx.font = '12px Arial';
          ctx.fillText('Score: ' + score, 10, 20);
      }
      
      // Check if the snake has collided with itself
      function isSnakeCollision(head) {
          for (var i = 1; i < snake.length; i++) {
              if (snake[i].x === head.x && snake[i].y === head.y) {
                  return true;
              }
          }
          return false;
      }
      
      // Control the snake with arrow keys
      document.addEventListener('keydown', function(event) {
          if (event.key === 'ArrowUp' && direction !== 'DOWN') direction = 'UP';
          if (event.key === 'ArrowDown' && direction !== 'UP') direction = 'DOWN';
          if (event.key === 'ArrowLeft' && direction !== 'RIGHT') direction = 'LEFT';
          if (event.key === 'ArrowRight' && direction !== 'LEFT') direction = 'RIGHT';
      });
      
      // Touch controls for mobile devices (swipe gestures)
      function handleTouchStart(event) {
          touchStart = event.touches[0]; // Capture the start of the touch
      }
      
      function handleTouchMove(event) {
          if (!touchStart) return;
      
          var touchEnd = event.touches[0];
          var dx = touchEnd.pageX - touchStart.pageX;
          var dy = touchEnd.pageY - touchStart.pageY;
      
          // Determine the direction of the swipe
          if (Math.abs(dx) > Math.abs(dy)) {
              if (dx > 0 && direction !== 'LEFT') direction = 'RIGHT';
              if (dx < 0 && direction !== 'RIGHT') direction = 'LEFT';
          } else {
              if (dy > 0 && direction !== 'UP') direction = 'DOWN';
              if (dy < 0 && direction !== 'DOWN') direction = 'UP';
          }
      
          touchStart = null; // Reset the touch start point
      }
      
      // Add touch event listeners for swipe gestures
      canvas.addEventListener('touchstart', handleTouchStart);
      canvas.addEventListener('touchmove', handleTouchMove);
      
      // Start the game
      function startGame() {
          score = 0;
          snake = [{x: 50, y: 50}, {x: 40, y: 50}, {x: 30, y: 50}];
          direction = 'RIGHT';
          food = {x: Math.floor(Math.random() * (canvas.width / 10)) * 10, y: Math.floor(Math.random() * (canvas.height / 10)) * 10};
          gameOver = false;
          gameInterval = setInterval(updateGame, 100);
      }
      
      // Create a start button to begin the game
      var startBtn = document.createElement('button');
      startBtn.innerText = 'Start Game';
      startBtn.onclick = function() {
          modal.removeChild(startBtn);
          startGame();
      };
      modal.appendChild(startBtn);
      
      // Create a close button to close the game and modal
      var closeBtn = document.createElement('button');
      closeBtn.innerText = 'Close Game';
      closeBtn.style.marginTop = '10px';
      closeBtn.onclick = function() {
          clearInterval(gameInterval); // Stop the game loop
          modal.removeChild(canvas); // Remove the game canvas
          modal.removeChild(startBtn); // Remove the start button
          modal.removeChild(closeBtn); // Remove the close button
          modal.innerHTML = ''; // Clear the modal content
      };
      modal.appendChild(closeBtn);
      """
        }
        
    }
    
    


}
