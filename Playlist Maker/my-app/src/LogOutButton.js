import React, { useEffect, useState } from "react";
import axios from "axios";
import './LoginButton.css'
import 'reactjs-popup/dist/index.css';


const USER_ENDPOINT = "https://api.spotify.com/v1/me";

const LogOutButton = () => {
  const [token, setToken] = useState("");
  const [data, setData] = useState({});

  useEffect(() => {
    if (localStorage.getItem("accessToken")) {
      setToken(localStorage.getItem("accessToken"));
    }
  }, []);

    axios
        .get(USER_ENDPOINT, {
        headers: {
            Authorization: "Bearer " + token,
        },
        })
        .then((response) => {
        setData(response.data);
        })
        .catch((error) => {
        console.log(error);
        });

  return (
    <>
    {data?.images && data.images[0] ? <button class="button"><img src={data.images[0].url} height="80" width="80"></img></button> : null}
    </>
  );
};






export default LogOutButton