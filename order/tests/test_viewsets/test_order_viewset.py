import json

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient, APITestCase

from order.factories import OrderFactory, UserFactory
from order.models import Order
from product.factories import CategoryFactory, ProductFactory
from product.models import Product


class TestOrderViewSet(APITestCase):

    client = APIClient()

    def setUp(self):
        self.category = CategoryFactory(title="technology")
        self.product = ProductFactory(
            title="mouse", price=100, category=[self.category]
        )
        self.order = OrderFactory(product=[self.product])

    def test_order(self):
        response = self.client.get(
            reverse("order-list", kwargs={"version": "v1"}))

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        order_data = json.loads(response.content)
        self.assertIsInstance(order_data, list)  # Verifica se é uma lista
        # Verifica se a lista não está vazia
        self.assertTrue(len(order_data) > 0)

        order_info = order_data[0]  # Obtem o primeiro item da lista
        # Verifica se o item é um dicionário
        self.assertIsInstance(order_info, dict)

        # Obtém as informações do produto
        product_info = order_info["product"][0]
        self.assertEqual(product_info["title"], self.product.title)
        self.assertEqual(product_info["price"], self.product.price)
        self.assertEqual(product_info["active"], self.product.active)
        self.assertEqual(product_info["category"]
                         [0]["title"], self.category.title)

    def test_create_order(self):
        user = UserFactory()
        product = ProductFactory()
        data = json.dumps({"products_id": [product.id], "user": user.id})

        response = self.client.post(
            reverse("order-list", kwargs={"version": "v1"}),
            data=data,
            content_type="application/json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        created_order = Order.objects.get(user=user)
