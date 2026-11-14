"""Quiz tests: schema, one correct answer, unique ids, CLI round trip."""

import glob
import json
import os
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "lib"))
import miniyaml  # noqa: E402

try:
    import yaml  # type: ignore
except ImportError:  # pragma: no cover
    yaml = None

QUIZZES = sorted(glob.glob(os.path.join(ROOT, "modules", "*", "quizzes", "*.yaml")))


class QuizTest(unittest.TestCase):
    def test_there_are_quizzes(self):
        self.assertGreaterEqual(len(QUIZZES), 30)

    def test_schema(self):
        ids = set()
        for path in QUIZZES:
            q = miniyaml.load(path)
            rel = os.path.relpath(path, ROOT)
            with self.subTest(quiz=rel):
                module = rel.split("/")[1]
                stem = os.path.splitext(os.path.basename(path))[0]
                self.assertEqual(q["id"], "%s/%s" % (module, stem))
                self.assertNotIn(q["id"], ids)
                ids.add(q["id"])
                self.assertTrue(0 < float(q["pass_mark"]) <= 1)
                lesson = os.path.join(ROOT, "modules", module, "lessons", stem + ".md")
                self.assertTrue(os.path.exists(lesson), "no lesson for this quiz")
                n = len(q["questions"])
                short = "short: true" in open(lesson, encoding="utf-8").read().split("\n---\n", 1)[0]
                self.assertTrue((3 if short else 4) <= n <= 6, "%d questions" % n)

    def test_questions(self):
        for path in QUIZZES:
            q = miniyaml.load(path)
            qids = [x["id"] for x in q["questions"]]
            with self.subTest(quiz=os.path.relpath(path, ROOT)):
                self.assertEqual(len(qids), len(set(qids)), "duplicate question ids")
            for x in q["questions"]:
                with self.subTest(quiz=os.path.relpath(path, ROOT), question=x["id"]):
                    self.assertTrue(str(x["prompt"]).strip())
                    opts = x["options"]
                    self.assertIsInstance(opts, dict)
                    self.assertTrue(3 <= len(opts) <= 6)
                    self.assertTrue(set(opts) <= set("abcdef"), "option keys %s" % sorted(opts))
                    self.assertEqual(sorted(opts), list("abcdef"[:len(opts)]), "keys must be a, b, c, ...")
                    for v in opts.values():
                        self.assertIsInstance(v, str)
                        self.assertTrue(v.strip())
                    self.assertEqual(len(set(o.strip().lower() for o in opts.values())), len(opts),
                                     "duplicate options")
                    # exactly one correct answer: a single key that exists
                    self.assertIsInstance(x["answer"], str)
                    self.assertIn(x["answer"], opts)
                    self.assertTrue(str(x["explanation"]).strip())

    def test_answers_not_all_the_same_letter(self):
        letters = [x["answer"] for p in QUIZZES for x in miniyaml.load(p)["questions"]]
        top = max(letters.count(c) for c in set(letters))
        self.assertLess(top / len(letters), 0.75, "answers are too predictable")

    def test_matches_pyyaml(self):
        if yaml is None:
            self.skipTest("PyYAML not installed")
        for path in QUIZZES:
            with self.subTest(quiz=os.path.relpath(path, ROOT)):
                with open(path, encoding="utf-8") as fh:
                    self.assertEqual(miniyaml.load(path), yaml.safe_load(fh))

    def test_cli_round_trip(self):
        path = QUIZZES[0]
        q = miniyaml.load(path)
        answers = ",".join(x["answer"] for x in q["questions"])
        with tempfile.TemporaryDirectory() as tmp:
            env = dict(os.environ, COURSE_PROGRESS_FILE=os.path.join(tmp, "p.json"), NO_COLOR="1")
            r = subprocess.run([sys.executable, os.path.join(ROOT, "bin", "course"), "quiz", q["id"],
                                "--answers", answers], env=env, capture_output=True, text=True)
            self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
            self.assertIn("PASSED", r.stdout)
            prog = json.load(open(os.path.join(tmp, "p.json")))
            self.assertTrue(prog["quizzes"][q["id"]]["passed"])
            wrong = ",".join(("b" if x["answer"] == "a" else "a") for x in q["questions"])
            r = subprocess.run([sys.executable, os.path.join(ROOT, "bin", "course"), "quiz", q["id"],
                                "--answers", wrong], env=env, capture_output=True, text=True)
            self.assertEqual(r.returncode, 1)


if __name__ == "__main__":
    unittest.main()
