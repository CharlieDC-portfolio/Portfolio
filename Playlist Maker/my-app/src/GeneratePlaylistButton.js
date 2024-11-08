import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './LoginButton.css';
import 'reactjs-popup/dist/index.css';

const PlaylistData = {
  name: 'PlaceHolder Name',
  description: 'Placeholder description',
  public: false,
};

const GeneratePlaylistButton = () => {
  const [token, setToken] = useState('');
  const [userId, setUserId] = useState(null);
  const [responseMessage, setResponseMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [data2, setData2] = useState(null);

  // Set token from localStorage if available
  useEffect(() => {
    const storedToken = localStorage.getItem('accessToken');
    if (storedToken) {
      setToken(storedToken);
    }
  }, []);

  // Fetch user data (userId) when the token is available
  useEffect(() => {
    if (token) {
      setLoading(true);

      axios
        .get('https://api.spotify.com/v1/me', {
          headers: { 'Authorization': `Bearer ${token}` },
        })
        .then((response) => {
          setUserId(response.data.id);
          setLoading(false);
        })
        .catch((error) => {
          setLoading(false);
          console.error('Error fetching user data:', error);
        });
    }
  }, [token]);

  // Handle playlist generation
  const handlePlaylistGeneration = () => {
    if (!userId) {
      console.error('User ID is not available yet!');
      return;
    }

    setLoading(true);

    // Fetch track URIs from the backend (http://localhost:5000/playlister)
    fetch('http://localhost:5000/playlister', {
      headers: { 'Content-Type': 'application/json' },
    })
      .then((response) => response.json())
      .then((data) => {
        // Extract track URIs from the response object
        const trackUris = Object.values(data);  // This will get an array of track URIs
        setData2(trackUris);  // Optionally store the track URIs in state for display
        return trackUris;  // Return track URIs to chain the playlist creation logic
      })
      .then((trackUris) => {
        // Step 1: Create the playlist on Spotify
        const CREATE_PLAYLISTS_ENDPOINT = `https://api.spotify.com/v1/users/${userId}/playlists`;

        axios
          .post(CREATE_PLAYLISTS_ENDPOINT, PlaylistData, {
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json',
            },
          })
          .then((playlistResponse) => {
            const playlistId = playlistResponse.data.id;  // Get the playlist ID from the response

            // Step 2: Add tracks to the newly created playlist
            const ADD_TRACKS_ENDPOINT = `https://api.spotify.com/v1/playlists/${playlistId}/tracks`;

            axios
              .post(
                ADD_TRACKS_ENDPOINT,
                { uris: trackUris },
                {
                  headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json',
                  },
                }
              )
              .then(() => {
                // Step 3: Update the response message
                setResponseMessage('Playlist created and tracks added successfully!');
                setLoading(false);
              })
              .catch((error) => {
                console.error('Error adding tracks to playlist:', error);
                setResponseMessage('Failed to add tracks to playlist.');
                setLoading(false);
              });
          })
          .catch((error) => {
            console.error('Error creating playlist:', error);
            setResponseMessage('Failed to create playlist.');
            setLoading(false);
          });
      })
      .catch((error) => {
        console.error('Error fetching track URIs:', error);
        setResponseMessage('Failed to fetch track URIs.');
        setLoading(false);
      });
  };

  return (
    <div>
      <button className="buttonCreate" onClick={handlePlaylistGeneration} disabled={loading}>
        {loading ? 'Generating...' : 'Generate Playlist'}
      </button>
      {responseMessage && <p>{responseMessage}</p>}
    </div>
  );
};

export default GeneratePlaylistButton;
