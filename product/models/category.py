from django.db import models


class Category(models.Model):
    title = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)
    description = models.CharField(
        max_length=200, blank=True, null=True)  # Corrigido o nome do campo
    active = models.BooleanField(default=True)

    def __str__(self):  # Corrigido o método de representação do objeto
        return self.title
