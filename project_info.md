# Counter-Strike 2 Sentiment Analysis Project

## 1. Dataset Overview

This project utilizes a large-scale dataset of player reviews for **Counter-Strike 2 (CS2)**, including historical data from its predecessor, **CS:GO**. The data provides granular insights into player feedback, community sentiment, and the reception of game mechanics over time.

* **Source:** Steam Web API.
* **Volume:** Approximately **2.45 million** reviews.
* **Timeline:** Historical data up to **December 2025**.
* **Scope:** Covers the transition period from CS:GO to CS2, allowing for temporal sentiment analysis.
* **Language Note:** While the initial query filtered for "English," the classification relies on user-indicated tags. The dataset contains non-English reviews requiring further filtering.

---

## 2. Project Pipeline

This project employs a Deep Learning approach to analyze unstructured text data, moving beyond simple keyword matching to understand context, sarcasm, and gamer jargon.

### Phase 1: Data Ingestion & Cleaning
* **Ingestion:** Parsing the raw JSON dataset.
* **Unescaping:** Handling JSON escape sequences in review text.
* **Language Verification:** Secondary filtering (using `langdetect` or similar) to remove non-English reviews mislabeled by users.
* **Noise Reduction:** Removing ASCII art, spam, and extremely short "meme" reviews based on character count and `votes_funny` ratios.

### Phase 2: Model Engineering
* **Base Model:** **Twitter-roBERTa-base**. Selected for its pre-training on social media text, making it robust against slang, typos, and emojis.
* **Fine-Tuning:** The model is fine-tuned on a subset of the CS2 dataset to learn domain-specific terminology (e.g., "sub-tick," "nerf," "vac," "smurf").

### Phase 3: Inference & Analysis
* **Sentiment Prediction:** Classifying reviews into sentiment categories (Positive/Negative/Neutral) with confidence scores.
* **Insight Generation:**
    * **Temporal Trends:** Mapping sentiment changes against game updates.
    * **Aspect Analysis:** Correlating sentiment with specific keywords (e.g., Performance vs. Gameplay).
    * **Player Segmentation:** Analyzing sentiment based on `playtime_forever` (Veterans vs. New Players).

---

## 3. Data Dictionary

The dataset is structured in JSON format. Below are the definitions for the fields contained in the response object and the nested `reviews` list.

### A. Response Metadata (Global Stats)
*These fields describe the query results as a whole.*

| Column / Field | Type | Description |
| :--- | :--- | :--- |
| `success` | Integer | Status code. `1` indicates the query was successful. |
| `query_summary` | Object | Summary returned in the first request of the batch. |
| `num_reviews` | Integer | The number of reviews returned in the current response batch. |
| `review_score` | Integer | An aggregated score representing the game's overall rating on Steam. |
| `review_score_desc` | String | Text description of the score (e.g., "Overwhelmingly Positive"). |
| `total_positive` | Integer | Total number of positive reviews in the dataset query. |
| `total_negative` | Integer | Total number of negative reviews in the dataset query. |
| `total_reviews` | Integer | Total number of reviews matching the query parameters. |
| `cursor` | String | Token used to retrieve the next batch of reviews (pagination). |

### B. Review Data (Individual Entries)
*These fields exist for every single review within the `reviews` list.*

#### Author Information
| Column / Field | Type | Description |
| :--- | :--- | :--- |
| `author.steamid` | String | The user’s unique 64-bit Steam ID. |
| `author.num_games_owned` | Integer | Total number of games owned by the reviewer. |
| `author.num_reviews` | Integer | Total number of reviews written by this user across Steam. |
| `author.playtime_forever` | Integer | Lifetime playtime tracked in the app (in minutes). |
| `author.playtime_last_two_weeks`| Integer | Playtime tracked in the two weeks prior to the data retrieval. |
| `author.playtime_at_review` | Integer | Playtime recorded at the exact moment the review was posted. |
| `author.deck_playtime_at_review`| Integer | Playtime specifically on **Steam Deck** when the review was written. |
| `author.last_played` | Timestamp| Unix timestamp of when the user last played the game. |

#### Review Content & Metrics
| Column / Field | Type | Description |
| :--- | :--- | :--- |
| `recommendationid` | String | Unique ID for the review. |
| `language` | String | User-selected language tag (Note: May be inaccurate). |
| `review` | String | The actual text content of the review. **(Primary input for NLP)**. |
| `timestamp_created` | Timestamp| Unix timestamp when the review was originally posted. |
| `timestamp_updated` | Timestamp| Unix timestamp when the review was last edited. |
| `voted_up` | Boolean | `true` = Recommended (Positive); `false` = Not Recommended (Negative). |
| `votes_up` | Integer | Number of other users who clicked "Helpful" on this review. |
| `votes_funny` | Integer | Number of other users who clicked "Funny" on this review. |
| `weighted_vote_score` | Float | Algorithmically calculated "helpfulness" score (0.0 to 1.0). |
| `comment_count` | Integer | Number of comments posted on this review thread. |

#### Contextual Metadata
| Column / Field | Type | Description |
| :--- | :--- | :--- |
| `steam_purchase` | Boolean | `true` if the user purchased the game directly on Steam. |
| `received_for_free` | Boolean | `true` if the user flagged that they received the game for free (e.g., gift, key). |
| `written_during_early_access` | Boolean | `true` if the review was posted while the game was in Early Access. |
| `primarily_steam_deck` | Boolean | `true` if the reviewer played primarily on Steam Deck at the time of writing. |
| `developer_response` | String | Text response from the developer (if applicable). |
| `timestamp_dev_responded` | Timestamp| Unix timestamp of the developer's response. |