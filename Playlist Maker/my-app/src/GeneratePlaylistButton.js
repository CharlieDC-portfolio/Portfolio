import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './LoginButton.css';
import 'reactjs-popup/dist/index.css';

const PlaylistData = {
  description: 'Placeholder description',
  public: false,
};

const GeneratePlaylistButton = () => {
  const [token, setToken] = useState('');
  const [userId, setUserId] = useState(null);
  const [responseMessage, setResponseMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [data2, setData2] = useState(null);

  // State for input values
  const [playlistName, setPlaylistName] = useState(''); // User input for playlist name
  const [playlistLength, setPlaylistLength] = useState('');
  const [trackId, setTrackId] = useState('');

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

    if (!trackId || !playlistLength || !playlistName) {
      console.error('Track ID, Playlist Length, and Playlist Name are required!');
      setResponseMessage('Please provide Track ID, Playlist Length, and Playlist Name.');
      return;
    }

    setLoading(true);

    // Send a POST request to your backend with trackId and playlistLength
    fetch('http://localhost:5000/playlister', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        trackId: trackId,
        playlistLength: parseInt(playlistLength, 10),
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        // Extract track URIs from the response object
        const trackUris = Object.values(data);  // This will get an array of track URIs
        setData2(trackUris);  // Optionally store the track URIs in state for display
        return trackUris;  // Return track URIs to chain the playlist creation logic
      })
      .then((trackUris) => {
        // Step 1: Create the playlist on Spotify with the user input playlist name
        const CREATE_PLAYLISTS_ENDPOINT = `https://api.spotify.com/v1/users/${userId}/playlists`;

        axios
          .post(CREATE_PLAYLISTS_ENDPOINT, {
            name: playlistName,  // Use the user-inputted playlist name here
            ...PlaylistData,  // Keep the rest of the PlaylistData
          }, {
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
      <div className="input-group">
        <label htmlFor="playlistName">Playlist Name</label>
        <input
          id="playlistName"
          type="text"
          value={playlistName}
          onChange={(e) => setPlaylistName(e.target.value)} // Update playlist name on change
          placeholder="Input Playlist Name"
        />
      </div>
      <div className="input-group">
        <label htmlFor="trackId">Track ID</label>
        <input
          id="trackId"
          type="text"
          value={trackId}
          onChange={(e) => setTrackId(e.target.value)}
          placeholder="Input Track ID"
        />
      </div>
      <div className="input-group">
        <label htmlFor="playlistLength">Playlist Length</label>
        <input
          id="playlistLength"
          type="number"
          value={playlistLength}
          onChange={(e) => setPlaylistLength(e.target.value)}
          placeholder="Input Playlist Length"
        />
      </div>
      <button className="buttonCreate" onClick={handlePlaylistGeneration} disabled={loading}>
        {loading ? 'Generating...' : 'Generate Playlist'}
      </button>
      {responseMessage && <p>{responseMessage}</p>}
    </div>
  );
};

export default GeneratePlaylistButton;
