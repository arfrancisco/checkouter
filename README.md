# README

This a very basic app that creates orders, adds items, removes items, and apply promotions as necessary. 

The core of everything is the `::CheckoutFlow` module. This serves as an interface for whatever delivery layer will be used. For this it's stil just the default Rails controller.
The `::CheckoutFlow` module should have all the necessary information of how the users or system will be interacting with it plus whatever active promotions are currently in place.

The promotions all follow a similar pattern so that it should be relatively easy to change or add new ones. A promotion needs to have a unique promo code that will be associated 
to the products so that it can be applied to them when they meet the criteria.
