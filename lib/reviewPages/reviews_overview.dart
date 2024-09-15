import 'package:flutter/material.dart';

import 'package:myapp/models/globals.dart';
import 'add_review.dart';

class ReviewsOverview extends StatefulWidget {
  const ReviewsOverview({Key? key}) : super(key: key);

  @override
  State<ReviewsOverview> createState() => ReviewsOverviewState();
}

class ReviewsOverviewState extends State<ReviewsOverview> {
  double score = 0;

  // Function to retrieve the score from the selected location's review list
  getScore() {
    if (Globals.selectedLocation.reviewList.isNotEmpty) {
      score = double.parse(Globals.selectedLocation.reviewScore);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call getScore to update the score value
    Globals.convertFutureToList();
    getScore();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: Stack(children: [
          Column(
            children: [
              Container(
                  margin: const EdgeInsets.all(10),
                  child: Text(
                    Globals.selectedLocation.reviewScore,
                    style: const TextStyle(fontSize: 50),
                  )),
              const SizedBox(
                height: 20,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.star,
                  color: (score >= 1) ? Colors.yellow : Colors.grey,
                  size: 50,
                ),
                Icon(
                  Icons.star,
                  color: (score >= 2) ? Colors.yellow : Colors.grey,
                  size: 50,
                ),
                Icon(
                  Icons.star,
                  color: (score >= 3) ? Colors.yellow : Colors.grey,
                  size: 50,
                ),
                Icon(
                  Icons.star,
                  color: (score >= 4) ? Colors.yellow : Colors.grey,
                  size: 50,
                ),
                Icon(
                  Icons.star,
                  color: (score >= 5) ? Colors.yellow : Colors.grey,
                  size: 50,
                ),
              ]),
              const SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display each review in the selected location's review list
                      for (var review in Globals.selectedLocation.reviewList)
                        Container(
                          margin: const EdgeInsets.all(10),
                          width: 300,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 7,
                                offset: Offset(4, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review['author'],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      '${review['score']} ⭐',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ]),
                              const Divider(
                                color: Colors.pinkAccent,
                                thickness: 0.2,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(children: [
                                Text(
                                  review['text'],
                                ),
                              ]),
                            ],
                          ),
                        )
                    ]),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the AddReviewPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddReviewPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(15),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          )
        ]),
      ),
    );
  }
}
