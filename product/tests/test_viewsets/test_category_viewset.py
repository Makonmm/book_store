import json

from django.urls import reverse
from rest_framework.test import APIClient, APITestCase
from rest_framework.views import status

from product.factories import CategoryFactory
from product.models import Category


class CategoryViewSetTest(APITestCase):
    client = APIClient()

    def setUp(self):
        self.category = CategoryFactory(title="books")

    def test_get_all_category(self):
        response = self.client.get(
            reverse("category-list", kwargs={"version": "v1"}))

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        # Verifica se a resposta está no formato JSON
        self.assertEqual(response["Content-Type"], "application/json")

        # Converte a resposta em um dicionário Python
        category_data = response.json()

        # Verifica se a resposta contém uma chave "results"
        self.assertTrue("results" in category_data)

        # Verifica se há pelo menos uma categoria na resposta
        self.assertTrue(len(category_data["results"]) > 0)

        # Verifica se o título da primeira categoria na resposta corresponde ao título da categoria criada no setUp()
        self.assertEqual(category_data["results"]
                         [0]["title"], self.category.title)

    def test_create_category(self):
        data = {"title": "technology"}

        response = self.client.post(
            reverse("category-list", kwargs={"version": "v1"}),
            data=data,
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        created_category = Category.objects.get(title="technology")
        self.assertEqual(created_category.title, "technology")
