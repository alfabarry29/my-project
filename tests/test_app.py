import unittest

from src.app import app


class HomeTest(unittest.TestCase):
    def test_home_returns_greeting(self):
        response = app.test_client().get("/")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_data(as_text=True), "Hello from DevOps Project!")
