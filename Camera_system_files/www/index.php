olas amigos from team 8
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Web Page</title>
</head>
<body>
    <h1>Welcome to My Web Page</h1>
    <?php
    //$imagePath = "/home/nates/final_assignment/photo_system/photos/2024-04-30/143138_023.jpg"; // Path to the image file
    $imagePath = "/var/www/html/uploads/152313_908.jpg";
    if (file_exists($imagePath)) {
        echo '<img src="' . $imagePath . '" alt="My Image">';
    } else {
        echo '<p>Image not found</p>';
    }
    echo '<p> Image not found </p>';
    ?>
</body>
</html>

