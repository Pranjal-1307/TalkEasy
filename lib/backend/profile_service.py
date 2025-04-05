from firebase_config import db

def update_profile(user_id: str, name: str):
    """Update user profile in Firestore."""
    if not user_id or not name:
        return {"error": "Missing user ID or name"}

    user_ref = db.collection("users").document(user_id)
    user_ref.set({"user_id": user_id, "name": name})

    return {"message": "Profile updated successfully!"}
