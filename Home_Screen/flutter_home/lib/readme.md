c1, Every app needs to "turn on" and "get its tools."

import: Imagine you are in a workshop. To build a table, you need a hammer and saw. material.dart is the "Toolbox" provided by Google. It contains all the buttons, text styles, and colors we see on the screen.

void main(): This is the entry point. In C++ or Java, it’s the same. When the phone clicks the app icon, it runs this function first.

runApp(): This command takes your code and says, "Display this on the screen now."


c2, Before you design a specific screen, you need to tell the phone what kind of app this is.

MaterialApp: This is the "Container" for the whole app. It handles big things like the App Title, the Theme (Dark or Light mode), and which screen should show up first (home).

StatelessWidget: This tells Flutter, "This part of the app is just a shell; it doesn't change its own data."


c3, Every screen needs a Scaffold.
Think of a Scaffold like a house frame. It has specific "slots" for:

The Body (The rooms/furniture).

The Floating Button (The doorbell).

The Bottom Bar (The floor/foundation).


c4, Inside the body of the Scaffold, we used SafeArea.
The Problem: Modern phones have "notches" (the black camera hole) and rounded corners.

The Solution: SafeArea acts as a shield. It measures the screen and pushes your content down just enough so it doesn't hide behind the camera or the clock.


The Column (Vertical Layout)
This is how you put things on top of each other.
children: [ ]: Notice the square brackets. In programming, brackets usually mean a List. A Column can hold many things, so we list them one by one.

c5, The Column (Vertical Layout)
This is how you put things on top of each other.


children: [ ]: Notice the square brackets. In programming, brackets usually mean a List. A Column can hold many things, so we list them one by one.



c6, The Container (The Stylist)
In standard HTML, this would be a div. In Flutter, a Container allows you to combine painting, positioning, and sizing.

double.infinity: This is a great trick. Instead of guessing how many pixels wide a phone is, you tell Flutter "just fill the space."

BoxDecoration: You cannot give a Container a color or rounded corners without this. It’s the "styling engine."

borderRadius: In your project, we used 25. If you change it to 50, the box becomes very round. If you change it to 0, it becomes a sharp rectangle.



c7, The Row (Horizontal Layout)
Inside that dark Container, we wanted "Income" on the left and "Expense" on the right. For this, we use a Row.


MainAxisAlignment.spaceBetween: This is the most important part of a Row. It tells Flutter: "Put the first item at the start and the last item at the end, and leave all the empty space in the middle."

The Cross Axis: While a Column cares about top-to-bottom, a Row cares about left-to-right.


c8, : The "Helper" Functions
You noticed _buildStatItem and _buildNavItem at the bottom of the code.

Instead of writing the same Column, Text, and Icon code three times for the bottom menu, we wrote it once in a function and just called it three times with different names.

Clean Code: It makes your build method shorter and easier to read.

Easy Fixes: If you want to change the font size of all menu items, you only change it in one place (the function) instead of three.



c9, The Stack (Putting Things on Top)
Look at your Figma design again. See that green Floating Action Button (the "+" button)? It looks like it is floating above the bottom bar and the white background.

In Flutter, when you want to put one widget literally on top of another (like placing a sticker on a notebook), you use a Stack.

How it works in your code:
The Scaffold actually handles this for you automatically! When you use the floatingActionButton property, the Scaffold "Stacks" that button on top of everything else.


c10, The "Children" vs "Child" Rule

child: Used when a widget can only hold one thing.

Example: A Container or SafeArea. They are like a single box.

children: Used when a widget can hold a list of things.

Example: Column and Row. They use square brackets [ ] because they are arrays/lists.


c11, Constraints (How Big is a Widget?)

Inside-Out: By default, a Container shrinks to fit whatever is inside it. If you add more text, the card gets taller.

Outside-In: If we give it a specific height (like height: 200), it will stay that size even if the text is small.

In our code:
We didn't give the card a height. We gave it padding. This means the card says: "I will be just big enough to hold the text, plus 25 pixels of air on every side." This is "Responsive Design"—it looks good on both small and large phones!


c12 The Bottom Bar Structure

Your Figma shows three icons: Home, Charts, and Records. We used a Row for this inside the BottomAppBar.

MainAxisAlignment.spaceAround: This is slightly different from spaceBetween. It puts equal space around each icon, so they aren't touching the very edges of the screen.