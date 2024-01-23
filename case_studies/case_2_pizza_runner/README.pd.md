## 8 Week SQL Challenge
# Case Study # 2: Pizza Runner 🍕🏃🏽‍♀️
**Author:** Andres Guerrero <br />
**Email:** peqwar@gmail.com <br />
**LinkedIn:** <a href="https://www.linkedin.com/in/peqwar/" target="_blank">https://www.linkedin.com/in/peqwar/</a>

**Published:** January 23, 2024

## Introduction
Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Problem Statement
Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.


## Datasets used
Key datasets for this case study:
- **runners** : The table shows the **registration_date** for each new runner
- **customer_orders** : Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order. The `pizza_id` relates to the type of pizza which was ordered whilst the `exclusions` are the ingredient_id values which should be removed from the pizza and the `extras` are the ingredient_id values which need to be added to the pizza.
- **runner_orders** : After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer. The `pickup_time` is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The `distance` and `duration` fields are related to how far and long the runner had to travel to deliver the order to the respective customer.
- **pizza_names** : Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!
- **pizza_recipes** : Each `pizza_id` has a standard set of toppings which are used as part of the pizza recipe.
- **pizza_toppings** : The table contains all of the `topping_name` values with their corresponding `topping_id` value

## Case Study
[Case Study #2 - Pizza Runner: SQL Solutions](./pizza_runner_solutions.md)

## About the challenge:
> **Creator:** Danny Ma 
> - https://www.linkedin.com/in/datawithdanny/ 
> - https://www.datawithdanny.com/
>
> **Website:** 
> - https://8weeksqlchallenge.com/