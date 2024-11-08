import { Routes, Route } from 'react-router-dom';
import LoggedOutPage from './LoggedOutPage';
import Callback from './Callback';
 
const App = () => {
   return (
      <>
         <Routes>
            <Route path="/" element={<LoggedOutPage />} />
            <Route path="/Callback" element={<Callback />} />
         </Routes>
      </>
   );
};
 
export default App;